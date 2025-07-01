import os

import pyodbc
from dotenv import load_dotenv
from mcp.server.fastmcp import FastMCP

# Cargar variables de entorno
load_dotenv()

CONN_STR = os.environ["SQL_CONN_STRING"]

mcp = FastMCP(name="azuresql", port=8000)


@mcp.resource("schema://main")
def sql_get_schema() -> str:
    """Devuelve el esquema de la base de datos Azure SQL."""
    print("get_schema called")
    with pyodbc.connect(CONN_STR) as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT TABLE_SCHEMA + '.' + TABLE_NAME "
            "FROM INFORMATION_SCHEMA.TABLES "
            "WHERE TABLE_TYPE='BASE TABLE';"
        )
        tables = cursor.fetchall()
    return "\n".join(row[0] for row in tables)


@mcp.tool()
def sql_query_data(sql: str) -> str:
    """Ejecuta consultas SELECT en Azure SQL."""
    print("sql_query_data called")
    try:
        with pyodbc.connect(CONN_STR) as conn:
            cursor = conn.cursor()
            cursor.execute(sql)
            results = cursor.fetchall()
        return "\n".join(str(tuple(row)) for row in results)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def sql_write_data(sql: str, params: tuple = ()) -> str:
    """Ejecuta INSERT/UPDATE/DELETE en Azure SQL."""
    print("sql_write_data called")
    try:
        with pyodbc.connect(CONN_STR) as conn:
            cursor = conn.cursor()
            cursor.execute(sql, params)
            conn.commit()
        return f"Operación exitosa, filas afectadas: {cursor.rowcount}"
    except Exception as e:
        return f"Error al ejecutar operación: {e}"


if __name__ == "__main__":
    mcp.run(transport="sse")
