import os
import psycopg
from fastapi import FastAPI

app = FastAPI()

WRITE_DB = os.getenv("DATABASE_URL")
READ_DB = os.getenv("READ_DATABASE_URL")


@app.on_event("startup")
def iniciar():
    with psycopg.connect(WRITE_DB) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS mensajes (
                id SERIAL PRIMARY KEY,
                texto TEXT NOT NULL
            )
        """)


@app.post("/mensajes")
def crear(texto: str):
    with psycopg.connect(WRITE_DB) as conn:
        conn.execute(
            "INSERT INTO mensajes (texto) VALUES (%s)",
            (texto,)
        )
    return {"mensaje": "Guardado en db1"}


@app.get("/mensajes")
def listar():
    with psycopg.connect(READ_DB) as conn:
        filas = conn.execute(
            "SELECT id, texto FROM mensajes ORDER BY id"
        ).fetchall()

    return [{"id": f[0], "texto": f[1]} for f in filas]