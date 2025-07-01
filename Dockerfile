# Etapa única basada en Python 3.12-slim
FROM python:3.12-slim

# 1. Instalar herramientas de compilación y ODBC Driver 18
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \               
    gnupg \              
    unixodbc-dev && \ 
    # 2. Configurar repositorio Microsoft
    curl -sSL -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && \
    # 3. Instalar driver y herramientas
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y \
    msodbcsql18 \         
    mssql-tools18 && \    
    # 4. Kerberos (solo Debian slim)
    apt-get install -y \
    libgssapi-krb5-2 && \ 
    # 5. Limpieza
    rm -rf /var/lib/apt/lists/*

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