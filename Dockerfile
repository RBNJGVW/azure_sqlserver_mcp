# Etapa única basada en Python 3.12-slim
FROM python:3.12-slim

# 1. Instalar herramientas de compilación y ODBC Driver 18
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    unixodbc-dev \
    build-essential && \
    # Agrega repositorio de Microsoft y instala el driver ODBC
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list \
    > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools && \
    rm -rf /var/lib/apt/lists/*  
# :contentReference[oaicite:0]{index=0}

# 2. Directorio de trabajo
WORKDIR /app

# 3. Copiar dependencias e instalarlas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt  
# :contentReference[oaicite:1]{index=1}

# 4. Copiar el código fuente de tu servidor
COPY . .

# 5. Exponer el puerto del MCP
EXPOSE 8000

# 6. Comando de arranque
CMD ["python", "-u", "azure_sqlserver_mcp_server.py"]