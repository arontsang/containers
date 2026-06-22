FROM node:alpine AS install

COPY / /app
WORKDIR /app
RUN npm install


FROM node:alpine
COPY --from=install /app /app

WORKDIR /app
EXPOSE 3128

ENTRYPOINT ["npm", "start"]
