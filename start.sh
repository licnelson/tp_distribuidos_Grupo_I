#!/bin/bash
export JWT_SECRET="RentarClaveSecreta2026ParaJWT123456789"
source api-gateway/venv/bin/activate
cd api-gateway
uvicorn app.main:app --reload > gateway.log 2>&1 &
