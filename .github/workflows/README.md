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

### 3. Publish to Winget (`winget.yml`)

Workflow này tự động đăng ký phiên bản mới của KeyViz lên Windows Package Manager (Winget).

**Kích hoạt:**
- Khi một release được phát hành

## Cách sử dụng

### Tạo Release

1. Tạo tag mới với phiên bản (ví dụ: `v2.0.0`)
2. Tạo release mới từ tag đó
3. GitHub Actions sẽ tự động build ứng dụng cho tất cả các nền tảng và đính kèm các file build vào release
4. Sau khi release được phát hành, Winget workflow sẽ tự động đăng ký phiên bản mới lên Windows Package Manager

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

## Yêu cầu

- Đảm bảo rằng repository có secret `GITHUB_TOKEN` với quyền truy cập đủ để tải lên các tệp vào release
- Đối với Winget workflow, cần có secret `WINGET_TOKEN` với quyền truy cập đủ để đăng ký gói lên Windows Package Manager 