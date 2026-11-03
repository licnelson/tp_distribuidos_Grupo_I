from typing import Annotated

import grpc
from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.generated.rentar.vehicle.v1 import vehicle_pb2
from app.grpc_clients.errors import GrpcServiceError
from app.grpc_clients.vehicle_client import VehicleGrpcClient
from app.schemas.vehicles import ExternalVehicleWriteRequest, VehicleResponse, VehicleWriteRequest
from app.grpc_clients.customer_client import CustomerGrpcClient
from app.security.dependencies import get_current_user, require_admin
from app.security.jwt import AuthenticatedUser


router = APIRouter(prefix="/api/vehiculos", tags=["Vehículos"])


def _vehicle_client(request: Request) -> VehicleGrpcClient:
    settings = request.app.state.settings
    return VehicleGrpcClient(
        target=settings.vehicle_grpc_target,
        timeout_seconds=settings.grpc_timeout_seconds,
    )


def _customer_client(request: Request) -> CustomerGrpcClient:
    settings = request.app.state.settings
    return CustomerGrpcClient(settings.customer_grpc_target, settings.grpc_timeout_seconds)


def _map_grpc_error(error: GrpcServiceError) -> HTTPException:
    if error.code == grpc.StatusCode.UNAVAILABLE:
        return HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Vehicle Service no disponible",
        )
    if error.code == grpc.StatusCode.DEADLINE_EXCEEDED:
        return HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Vehicle Service agotó el tiempo de respuesta",
        )
    if error.code == grpc.StatusCode.NOT_FOUND:
        return HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado",
        )
    if error.code == grpc.StatusCode.ALREADY_EXISTS:
        return HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="La patente ya esta registrada",
        )
    return HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail=f"Error de Vehicle Service: {error.details}",
    )


@router.get(
    "", response_model=list[VehicleResponse], summary="Listar vehículos",
    description="Obtiene los vehículos administrados por Vehicle Service. Requiere un JWT válido.",
    responses={401: {"description": "Token ausente o inválido."}, 503: {"description": "Vehicle Service no disponible."}},
)
async def list_vehicles(
    request: Request,
    _user: Annotated[AuthenticatedUser, Depends(get_current_user)],
) -> list[VehicleResponse]:
    """Devuelve los vehículos usando Vehicle Service mediante gRPC."""
    try:
        return await _vehicle_client(request).list_vehicles()
    except GrpcServiceError as error:
        raise _map_grpc_error(error) from error


@router.post(
    "", response_model=VehicleResponse, status_code=status.HTTP_201_CREATED,
    summary="Registrar vehículo", description="Crea un vehículo. Solo disponible para administradores.",
    responses={201: {"description": "Vehículo creado."}, 400: {"description": "Datos o tipo inválido."}, 401: {"description": "Token inválido."}, 403: {"description": "Se requiere rol administrador."}, 503: {"description": "Vehicle Service no disponible."}},
)
async def create_vehicle(
    data: VehicleWriteRequest,
    request: Request,
    _user: Annotated[AuthenticatedUser, Depends(require_admin)],
) -> VehicleResponse:
    try:
        return await _vehicle_client(request).create_vehicle(_vehicle_payload(data))
    except GrpcServiceError as error:
        raise _map_grpc_error(error) from error


@router.post(
    "/externos", response_model=VehicleResponse, status_code=status.HTTP_201_CREATED,
    summary="Registrar vehiculo externo",
    description=(
        "Registra un vehiculo de un cliente en estado PENDIENTE y dispara "
        "las validaciones asincronas de patente y titularidad mediante RabbitMQ."
    ),
    responses={
        201: {"description": "Vehiculo registrado y enviado a validacion."},
        400: {"description": "Datos invalidos."},
        403: {"description": "El cliente no puede registrar otro titular."},
        503: {"description": "Vehicle Service no disponible."},
    },
)
async def create_external_vehicle(
    data: ExternalVehicleWriteRequest,
    request: Request,
    user: Annotated[AuthenticatedUser, Depends(get_current_user)],
) -> VehicleResponse:
    try:
        cliente_id = data.clienteId
        if not user.es_admin:
            cliente_id = (await _customer_client(request).get_customer_by_email(user.email)).id
        elif cliente_id is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="clienteId es obligatorio para administradores")
        payload = _vehicle_payload(data)
        payload["cliente_id"] = cliente_id
        return await _vehicle_client(request).register_external_vehicle(payload)
    except GrpcServiceError as error:
        raise _map_grpc_error(error) from error


@router.put(
    "/{vehicle_id}", response_model=VehicleResponse, summary="Actualizar vehículo",
    description="Actualiza todos los datos de un vehículo existente. Solo administradores.",
    responses={404: {"description": "Vehículo inexistente."}, 401: {"description": "Token inválido."}, 403: {"description": "Se requiere rol administrador."}},
)
async def update_vehicle(
    vehicle_id: int,
    data: VehicleWriteRequest,
    request: Request,
    _user: Annotated[AuthenticatedUser, Depends(require_admin)],
) -> VehicleResponse:
    try:
        return await _vehicle_client(request).update_vehicle(
            vehicle_id,
            _vehicle_payload(data),
        )
    except GrpcServiceError as error:
        raise _map_grpc_error(error) from error


@router.delete(
    "/{vehicle_id}", summary="Dar de baja un vehículo",
    description="Realiza la baja lógica del vehículo. Solo administradores.",
    responses={200: {"description": "Baja realizada."}, 404: {"description": "Vehículo inexistente."}, 403: {"description": "Se requiere rol administrador."}},
)
async def delete_vehicle(
    vehicle_id: int,
    request: Request,
    _user: Annotated[AuthenticatedUser, Depends(require_admin)],
) -> dict[str, bool]:
    try:
        return {"success": await _vehicle_client(request).delete_vehicle(vehicle_id)}
    except GrpcServiceError as error:
        raise _map_grpc_error(error) from error


def _vehicle_payload(data: VehicleWriteRequest) -> dict:
    try:
        vehicle_type = vehicle_pb2.VehicleType.Value(f"VEHICLE_TYPE_{data.tipo.upper()}")
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Tipo de vehículo inválido: {data.tipo}",
        ) from error
    return {
        "patente": data.patente,
        "marca": data.marca,
        "modelo": data.modelo,
        "anio": data.anio,
        "color": data.color or "",
        "tipo": vehicle_type,
        "precio_diario": data.precioDiario,
    }
