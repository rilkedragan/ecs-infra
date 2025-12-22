FROM node:20 AS builder

WORKDIR /app

COPY package*.json ./
COPY yarn.lock .
RUN yarn install
COPY . .
RUN yarn build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
