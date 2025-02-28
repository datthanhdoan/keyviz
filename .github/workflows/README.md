# GitHub Actions cho KeyViz

Repository này chứa các GitHub Actions workflow để tự động hóa quy trình phát triển và phát hành KeyViz.

## Quy trình tự động hóa

Quy trình tự động hóa hoạt động như sau:

1. Khi bạn push code vào nhánh `main`, workflow `auto-release.yml` sẽ tự động tạo release mới
2. Sau khi release được tạo, các workflow khác (`build.yml`, `msix.yml`, `docker.yml`) sẽ tự động chạy để build ứng dụng và đính kèm các file build vào release

## Xử lý lỗi

Các workflow đã được cấu hình để tiếp tục chạy ngay cả khi có lỗi xảy ra:

- Nếu các bài kiểm tra thất bại, workflow vẫn sẽ tiếp tục
- Nếu quá trình build thất bại, các file placeholder sẽ được tạo để đảm bảo workflow không bị gián đoạn
- Tất cả các bước quan trọng đều có tùy chọn `continue-on-error: true` để đảm bảo workflow hoàn thành

## Workflows

### 1. Auto Create Release (`auto-release.yml`)

Workflow này tự động tạo release mới khi có push vào nhánh `main`.

**Kích hoạt:**
- Push vào nhánh `main` (ngoại trừ các file .md, .github/workflows, .gitignore)
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **create-release**
   - Lấy tag mới nhất và tăng số phiên bản
   - Kiểm tra xem có thay đổi nào kể từ tag cuối cùng không
   - Cập nhật phiên bản trong pubspec.yaml
   - Commit và push thay đổi
   - Tạo tag mới
   - Tạo release mới với danh sách các thay đổi

### 2. Build KeyViz (`build.yml`)

Workflow này tự động build ứng dụng KeyViz cho các nền tảng Windows, macOS và Linux.

**Kích hoạt:**
- Khi release được tạo hoặc xuất bản
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-windows**
   - Build ứng dụng cho Windows
   - Tạo file ZIP và đính kèm vào release
   - Xử lý lỗi nếu build thất bại

2. **build-macos**
   - Build ứng dụng cho macOS
   - Tạo file DMG và đính kèm vào release
   - Xử lý lỗi nếu build thất bại

3. **build-linux**
   - Build ứng dụng cho Linux
   - Tạo file TAR.GZ và đính kèm vào release
   - Xử lý lỗi nếu build thất bại

### 3. Test KeyViz (`test.yml`)

Workflow này tự động kiểm tra code và chạy các bài kiểm tra (tests).

**Kích hoạt:**
- Push vào nhánh `main`
- Pull request vào nhánh `main`
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **analyze**
   - Kiểm tra định dạng code
   - Phân tích mã nguồn dự án
   - Tiếp tục ngay cả khi có lỗi

2. **test**
   - Chạy các bài kiểm tra tự động
   - Tiếp tục ngay cả khi có lỗi

### 4. Build Windows MSIX Package (`msix.yml`)

Workflow này tự động tạo gói cài đặt MSIX cho Windows.

**Kích hoạt:**
- Khi release được tạo hoặc xuất bản
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-msix**
   - Tạo gói cài đặt MSIX cho Windows
   - Đính kèm gói MSIX vào release
   - Xử lý lỗi nếu build thất bại

### 5. Build and Push Docker Image (`docker.yml`)

Workflow này tự động tạo và đẩy Docker image lên GitHub Container Registry.

**Kích hoạt:**
- Khi release được tạo hoặc xuất bản
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-and-push**
   - Tạo Docker image từ Dockerfile
   - Đẩy image lên GitHub Container Registry với các tag phiên bản
   - Tiếp tục ngay cả khi có lỗi

## Cách sử dụng

### Tự động tạo Release

Mỗi khi bạn push code vào nhánh `main`, workflow `auto-release.yml` sẽ tự động:
1. Tăng số phiên bản (patch version)
2. Tạo tag mới
3. Tạo release mới với danh sách các thay đổi
4. Cập nhật phiên bản trong pubspec.yaml

Sau khi release được tạo, các workflow khác sẽ tự động chạy để build ứng dụng và đính kèm các file build vào release.

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

## Giải quyết sự cố

Nếu bạn gặp vấn đề với các workflow, hãy thử các giải pháp sau:

1. **Workflow thất bại với lỗi "x"**:
   - Kiểm tra tab "Actions" để xem chi tiết lỗi
   - Đảm bảo rằng GITHUB_TOKEN có đủ quyền
   - Thử chạy workflow thủ công

2. **Không có release nào được tạo**:
   - Kiểm tra xem có thay đổi nào kể từ tag cuối cùng không
   - Đảm bảo rằng workflow `auto-release.yml` đã chạy thành công
   - Kiểm tra xem có lỗi nào trong quá trình tạo tag và release không

3. **File build không được đính kèm vào release**:
   - Kiểm tra xem release đã được tạo chưa
   - Đảm bảo rằng các workflow build đã chạy thành công
   - Kiểm tra xem có lỗi nào trong quá trình build không

## Yêu cầu

- Đảm bảo rằng repository có secret `GITHUB_TOKEN` với quyền truy cập đủ để tải lên các tệp vào release và đẩy Docker image
- `GITHUB_TOKEN` được GitHub tự động cung cấp, bạn không cần tạo hoặc thêm nó thủ công 