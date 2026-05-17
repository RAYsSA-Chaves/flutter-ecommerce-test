# Flutter Ecommerce Test

Rayssa Chaves Carvalho de Melo. 2DSTB - DS17.

---

Projeto desenvolvido para a disciplina **Programação para Dispositivos Móveis**.

O aplicativo simula um ecommerce básico de livros utilizando Flutter, com integração de APIs, armazenamento interno e operações básicas de CRUD.

---

## ⚙️ Configuração do projeto

1. Arquivo `.env`

Criar um arquivo `.env` dentro da pasta:

```txt
flutter-ecommerce-test/ecommerce_app/
```

Adicionar o seguinte conteúdo:

```env
API_URL=http://ip-da-sua-maquina
GOOGLE_BOOKS_API_KEY='sua-chave-de-api'
```

### 📌 Importante

#### API_URL

A URL deve conter o IP da máquina que está executando o `json-server`.

#### Chave da Google Books API

1. Acesse:
   - https://console.cloud.google.com/

2. Crie um projeto

3. Vá em:
   - APIs e Serviços

4. Ative:
   - Google Books API

5. Gere uma chave de API

6. Cole a chave no `.env`

---

2. Instalação das dependências

Acesse a pasta do projeto Flutter:

```bash
cd ecommerce_app
```

Execute:

```bash
flutter pub get
```

---

3. Executando a API local

Acesse a pasta:

```bash
cd api
```

Execute o comando:

```bash
json-server --watch db.json
```
