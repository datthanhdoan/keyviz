# GitHub Actions cho KeyViz

Repository này chứa các GitHub Actions workflow để tự động hóa quy trình phát triển và phát hành KeyViz.

## Quy trình CI/CD

Tài liệu này mô tả quy trình CI/CD được sử dụng trong dự án KeyViz.

## Các workflow

### Auto Create Release
File: `auto-release.yml`

Workflow này tự động tạo release khi có push vào nhánh `main` hoặc `develop`:

- **Nhánh `develop`**: Tạo pre-release với tag dựa trên timestamp, không tăng phiên bản trong pubspec.yaml
- **Nhánh `main`**: Tạo release chính thức, tăng phiên bản patch trong pubspec.yaml
- **Kích hoạt các workflow khác**: Sau khi tạo release, workflow này sẽ tự động kích hoạt các workflow build, msix và docker

### Build
File: `build.yml`

Workflow này build ứng dụng cho các nền tảng khác nhau (Windows, Linux, macOS) và đính kèm các file build vào release:

- Được kích hoạt khi có push vào nhánh `develop`, khi có release mới, sau khi workflow "Auto Create Release" hoàn thành, hoặc thủ công
- Kiểm tra xem release có phải là pre-release hay không để đặt tên file build phù hợp
- Các file build từ nhánh `develop` sẽ có hậu tố `-dev` để phân biệt

### MSIX Package
File: `msix.yml`

Workflow này tạo gói cài đặt MSIX cho Windows:

- Được kích hoạt khi có push vào nhánh `develop`, khi có release mới, sau khi workflow "Auto Create Release" hoàn thành, hoặc thủ công
- Kiểm tra xem release có phải là pre-release hay không để đặt tên file MSIX phù hợp
- File MSIX từ nhánh `develop` sẽ có hậu tố `-dev` để phân biệt

### Docker
File: `docker.yml`

Workflow này build và đẩy Docker image lên GitHub Container Registry:

- Được kích hoạt khi có push vào nhánh `develop`, khi có release mới, sau khi workflow "Auto Create Release" hoàn thành, hoặc thủ công
- Kiểm tra xem release có phải là pre-release hay không để đặt tag Docker phù hợp
- Docker image từ nhánh `develop` sẽ có hậu tố `-dev` để phân biệt

## Quy trình phát triển

1. Phát triển tính năng mới trên nhánh feature hoặc trực tiếp trên nhánh `develop`
2. Push code lên nhánh `develop` để tự động kích hoạt các workflow build, msix và docker
3. Kiểm tra các bản build
4. Khi sẵn sàng phát hành, merge nhánh `develop` vào `main`
5. Push code lên nhánh `main` để tạo release chính thức

## Xử lý lỗi

Tất cả các workflow đều được cấu hình để tiếp tục chạy ngay cả khi có lỗi xảy ra:

- Các bước build có thể thất bại nhưng workflow vẫn tiếp tục
- Nếu quá trình build thất bại, một file placeholder sẽ được tạo để đảm bảo workflow không bị gián đoạn
- Tất cả các bước quan trọng đều có `continue-on-error: true` để đảm bảo workflow hoàn thành

### Xử lý các vấn đề thường gặp

1. **Workflow không tạo release**:
   - Kiểm tra xem có thay đổi nào kể từ tag cuối cùng không
   - Đảm bảo bạn đang push vào nhánh `main` hoặc `develop`

2. **Các workflow khác không chạy sau khi push vào nhánh `develop`**:
   - Tất cả các workflow (build, msix, docker) đã được cấu hình để chạy trực tiếp khi có push vào nhánh `develop`
   - Kiểm tra log của các workflow để xem lỗi
   - Đảm bảo các file đã thay đổi không nằm trong paths-ignore

3. **File build không được đính kèm vào release**:
   - Kiểm tra log của workflow `build.yml` để xem lỗi
   - Đảm bảo workflow `auto-release.yml` đã hoàn thành thành công nếu đang sử dụng release

4. **Pre-release không được tạo từ nhánh `develop`**:
   - Kiểm tra log của workflow `auto-release.yml`
   - Đảm bảo bạn đang push vào nhánh `develop`

5. **Phân biệt giữa build từ nhánh `develop` và `main`**:
   - Các file build từ nhánh `develop` có hậu tố `-dev`
   - Các file build từ nhánh `main` không có hậu tố đặc biệt

## Workflows

### 1. Auto Create Release (`auto-release.yml`)

Workflow này tự động tạo release mới khi có push vào nhánh `main` hoặc `develop`.

**Kích hoạt:**
- Push vào nhánh `main` hoặc `develop` (ngoại trừ các file .md, .gitignore)
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **create-release**
   - Lấy tag mới nhất và tăng số phiên bản (chỉ cho nhánh `main`)
   - Kiểm tra xem có thay đổi nào kể từ tag cuối cùng không
   - Cập nhật phiên bản trong pubspec.yaml (chỉ cho nhánh `main`)
   - Commit và push thay đổi
   - Tạo tag mới
   - Tạo release mới với danh sách các thay đổi
   - Kích hoạt các workflow khác (build, msix, docker)

### 2. Build KeyViz (`build.yml`)

Workflow này tự động build ứng dụng KeyViz cho các nền tảng Windows, macOS và Linux.

**Kích hoạt:**
- Push vào nhánh `develop` (ngoại trừ các file .md, .gitignore, auto-release.yml)
- Khi release được tạo hoặc xuất bản
- Sau khi workflow "Auto Create Release" hoàn thành
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

### 3. Build Windows MSIX Package (`msix.yml`)

Workflow này tự động tạo gói cài đặt MSIX cho Windows.

**Kích hoạt:**
- Push vào nhánh `develop` (ngoại trừ các file .md, .gitignore, auto-release.yml)
- Khi release được tạo hoặc xuất bản
- Sau khi workflow "Auto Create Release" hoàn thành
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-msix**
   - Tạo gói cài đặt MSIX cho Windows
   - Đính kèm gói MSIX vào release
   - Xử lý lỗi nếu build thất bại

### 4. Build and Push Docker Image (`docker.yml`)

Workflow này tự động tạo và đẩy Docker image lên GitHub Container Registry.

**Kích hoạt:**
- Push vào nhánh `develop` (ngoại trừ các file .md, .gitignore, auto-release.yml)
- Khi release được tạo hoặc xuất bản
- Sau khi workflow "Auto Create Release" hoàn thành
- Thủ công thông qua workflow_dispatch

**Jobs:**

1. **build-and-push**
   - Tạo Docker image từ Dockerfile
   - Đẩy image lên GitHub Container Registry với các tag phiên bản
   - Tiếp tục ngay cả khi có lỗi

## Cách sử dụng

### Tự động build khi phát triển

Mỗi khi bạn push code vào nhánh `develop`, các workflow build, msix và docker sẽ tự động chạy để build ứng dụng. Điều này giúp bạn kiểm tra xem các thay đổi có ảnh hưởng đến quá trình build không.

### Tự động tạo Release

Mỗi khi bạn push code vào nhánh `main` hoặc `develop`, workflow `auto-release.yml` sẽ tự động:
1. Tạo release (pre-release cho nhánh `develop`, release chính thức cho nhánh `main`)
2. Kích hoạt các workflow khác để build ứng dụng và đính kèm các file build vào release

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