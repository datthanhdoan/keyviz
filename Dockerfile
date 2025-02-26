# Giai đoạn 1: Build ứng dụng Flutter
FROM ubuntu:22.04 AS builder

# Cài đặt các phụ thuộc cần thiết
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    lib32stdc++6 \
    libgtk-3-dev \
    libx11-dev \
    pkg-config \
    cmake \
    ninja-build \
    libblkid-dev \
    libayatana-appindicator3-dev \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt Flutter
ENV FLUTTER_HOME=/opt/flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN flutter channel stable && flutter upgrade && flutter config --no-analytics

# Sao chép mã nguồn ứng dụng
WORKDIR /app
COPY . .

# Lấy các phụ thuộc và build ứng dụng Linux
RUN flutter pub get
RUN flutter build linux --release

# Giai đoạn 2: Tạo image chạy ứng dụng
FROM ubuntu:22.04

# Cài đặt các phụ thuộc thời gian chạy
RUN apt-get update && apt-get install -y \
    libgtk-3-0 \
    libx11-6 \
    libayatana-appindicator3-1 \
    && rm -rf /var/lib/apt/lists/*

# Sao chép ứng dụng đã build từ giai đoạn trước
WORKDIR /app
COPY --from=builder /app/build/linux/x64/release/bundle/ .

# Thiết lập biến môi trường
ENV LD_LIBRARY_PATH=/app/lib

# Chạy ứng dụng
CMD ["./keyviz"] 