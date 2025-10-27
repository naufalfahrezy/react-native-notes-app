# ---------- Base: Node LTS ----------
FROM node:18-bullseye AS base
WORKDIR /app
ENV CI=true \
    # react-native/metro + file watching dalam container
    CHOKIDAR_USEPOLLING=true \
    WATCHPACK_POLLING=true \
    # agar expo-cli tidak minta interaktif
    EXPO_NO_INTERACTIVE=1

# ---------- Dev image: untuk expo/metro ----------
FROM base AS dev
# Copy definisi deps lebih dulu (cache-friendly)
COPY package*.json ./
# install deps (pakai npm karena ada package-lock.json)
RUN npm ci
# Copy sisa kode
COPY . .
# expo dan eas sebagai dev tooling
RUN npm i -g expo-cli eas-cli
EXPOSE 19000 19001 19002
# Jalankan expo (QR, LAN, web UI)
CMD ["bash", "-lc", "expo start --tunnel"]

# ---------- Web build (opsional): expo web ----------
FROM base AS webbuild
COPY package*.json ./
RUN npm ci && npm i -g expo-cli
COPY . .
# Build web (kalau kamu mau mode web)
RUN npx expo export --platform web --dump-sourcemap --clear

# ---------- Runtime web (opsional): nginx serve hasil build) ----------
FROM nginx:alpine AS web
COPY --from=webbuild /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
