FROM node:18-alpine AS builder

WORKDIR /app

RUN npm install -g expo-cli

COPY package*.json ./

RUN npm install

RUN npx expo install react-native-web@~0.19.6 react-dom@18.2.0 @expo/webpack-config@^19.0.0

COPY . .

RUN npx expo export:web

FROM nginx:alpine

COPY --from=builder /app/web-build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]