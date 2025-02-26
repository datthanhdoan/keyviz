# GitHub Actions cho KeyViz

Repository này chứa các GitHub Actions workflow để tự động hóa quy trình phát triển và phát hành KeyViz.

## Workflows

### 1. Build KeyViz (`build.yml`)

Workflow này tự động build ứng dụng KeyViz cho các nền tảng Windows, macOS và Linux.

**Kích hoạt:**
- Push vào nhánh `main`
- Pull request vào nhánh `main`
- Thủ công thông qua workflow_dispatch
- Khi tạo release mới

**Jobs:**

1. **build-windows**
   - Build ứng dụng cho Windows
   - Nếu được kích hoạt bởi release, tạo file ZIP và đính kèm vào release

2. **build-macos**
   - Build ứng dụng cho macOS
   - Nếu được kích hoạt bởi release, tạo file DMG và đính kèm vào release

3. **build-linux**
   - Build ứng dụng cho Linux
   - Nếu được kích hoạt bởi release, tạo file TAR.GZ và đính kèm vào release

### 2. Test KeyViz (`test.yml`)

Workflow này tự động kiểm tra code và chạy các bài kiểm tra (tests).

**Kích hoạt:**
- Push vào nhánh `main`
- Pull request vào nhánh `main`
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **analyze**
   - Kiểm tra định dạng code
   - Phân tích mã nguồn dự án

2. **test**
   - Chạy các bài kiểm tra tự động

### 3. Build Windows MSIX Package (`msix.yml`)

Workflow này tự động tạo gói cài đặt MSIX cho Windows.

**Kích hoạt:**
- Khi tạo release mới
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-msix**
   - Tạo gói cài đặt MSIX cho Windows
   - Nếu được kích hoạt bởi release, đính kèm gói MSIX vào release

### 4. Build and Push Docker Image (`docker.yml`)

Workflow này tự động tạo và đẩy Docker image lên GitHub Container Registry.

**Kích hoạt:**
- Khi tạo release mới
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-and-push**
   - Tạo Docker image từ Dockerfile
   - Đẩy image lên GitHub Container Registry với các tag phiên bản

## Cách sử dụng

### Tạo Release

1. Tạo tag mới với phiên bản (ví dụ: `v2.0.0`)
2. Tạo release mới từ tag đó
3. GitHub Actions sẽ tự động build ứng dụng cho tất cả các nền tảng và đính kèm các file build vào release

### Kiểm tra Build

Bạn có thể kích hoạt workflow build thủ công để kiểm tra xem ứng dụng có build thành công trên tất cả các nền tảng không:

1. Đi đến tab "Actions" trên GitHub repository
2. Chọn workflow "Build KeyViz"
3. Nhấp vào "Run workflow"
4. Chọn nhánh và nhấp vào "Run workflow"

### Kiểm tra Code

Bạn có thể kích hoạt workflow test thủ công để kiểm tra chất lượng code:

1. Đi đến tab "Actions" trên GitHub repository
2. Chọn workflow "Test KeyViz"
3. Nhấp vào "Run workflow"
4. Chọn nhánh và nhấp vào "Run workflow"

### Tạo Gói MSIX

Bạn có thể kích hoạt workflow MSIX thủ công để tạo gói cài đặt MSIX cho Windows:

1. Đi đến tab "Actions" trên GitHub repository
2. Chọn workflow "Build Windows MSIX Package"
3. Nhấp vào "Run workflow"
4. Chọn nhánh và nhấp vào "Run workflow"

### Sử dụng Docker Image

Sau khi workflow Docker chạy thành công, bạn có thể kéo và chạy Docker image từ GitHub Container Registry:

```bash
# Kéo image phiên bản mới nhất
docker pull ghcr.io/datthanhdoan/keyviz:latest

# Chạy container
docker run -d --name keyviz ghcr.io/datthanhdoan/keyviz:latest
```

## Yêu cầu

- Đảm bảo rằng repository có secret `GITHUB_TOKEN` với quyền truy cập đủ để tải lên các tệp vào release và đẩy Docker image
- `GITHUB_TOKEN` được GitHub tự động cung cấp, bạn không cần tạo hoặc thêm nó thủ công 