# GitHub Actions Visual Artifacts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the existing QingJian iOS CI workflow with simulator screenshots and a short video that can be downloaded from GitHub Actions.

**Architecture:** Keep the native app unchanged. After the existing simulator build, use `xcrun simctl` on the GitHub `macos-26` runner to boot/install/launch the app, capture fresh onboarding and Today states, record a short launch video, then upload the visual files as artifacts alongside logs and XCTest results.

**Tech Stack:** GitHub Actions YAML, Xcode 26.6, `xcrun simctl`, `actions/upload-artifact@v4`.

---

### Task 1: Add simulator visual capture to CI

**Files:**
- Modify: `.github/workflows/ios.yml`

- [ ] **Step 1: Add a visual capture step after the simulator build**

Add a `Capture simulator visuals` step that:

```yaml
      - name: Capture simulator visuals
        run: |
          set -euo pipefail
          app_path="$(find build/DerivedData/Build/Products/Debug-iphonesimulator -maxdepth 1 -name 'QingJian.app' -type d -print -quit)"
          test -n "$app_path"
          mkdir -p build/visuals
          device_id="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone 17 \(/ {print $2; exit}')"
          test -n "$device_id"
          trap 'xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true' EXIT
          xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true
          xcrun simctl erase "$device_id"
          xcrun simctl boot "$device_id" >/dev/null 2>&1 || true
          xcrun simctl bootstatus "$device_id" -b
          xcrun simctl install "$device_id" "$app_path"
          xcrun simctl launch "$device_id" com.qingjian.app
          sleep 4
          xcrun simctl io "$device_id" screenshot build/visuals/01-onboarding.png
          xcrun simctl terminate "$device_id" com.qingjian.app || true
          xcrun simctl spawn "$device_id" defaults write com.qingjian.app hasCompletedOnboarding -bool YES
          xcrun simctl launch "$device_id" com.qingjian.app
          sleep 4
          xcrun simctl io "$device_id" screenshot build/visuals/02-today.png
          xcrun simctl terminate "$device_id" com.qingjian.app || true
          xcrun simctl launch "$device_id" com.qingjian.app
          xcrun simctl io "$device_id" recordVideo --codec=h264 --force build/visuals/qingjian-launch.mp4 &
          video_pid=$!
          sleep 12
          kill "$video_pid" || true
          wait "$video_pid" || true
```

- [ ] **Step 2: Include visual files in the existing artifact**

Extend the upload paths with:

```yaml
            build/visuals/*
```

- [ ] **Step 3: Verify YAML and repository state locally**

Run:

```powershell
Get-Content -Raw .github/workflows/ios.yml
git -c safe.directory=D:/ios_app diff --check
```

Expected: the workflow contains the visual step and `git diff --check` emits no output.

- [ ] **Step 4: Commit and push the workflow**

Run:

```powershell
git -c safe.directory=D:/ios_app add .github/workflows/ios.yml docs/superpowers/specs/2026-08-10-ci-visual-artifacts-design.md docs/superpowers/plans/2026-08-10-ci-visual-artifacts-plan.md
git -c safe.directory=D:/ios_app commit -m "ci: upload simulator screenshots and video"
git -c safe.directory=D:/ios_app -c http.version=HTTP/1.1 push origin main
```

### Task 2: Verify the cloud visual artifacts

**Files:**
- Verify: GitHub Actions run for the pushed commit

- [ ] **Step 1: Confirm all workflow steps finish successfully**

Check the Actions run API and confirm `Build for iOS Simulator`, `Capture simulator visuals`, `Run XCTest on iOS Simulator`, and `Upload XCTest results` all have conclusion `success`.

- [ ] **Step 2: Confirm artifact contents**

Check the run’s artifact named `qingjian-xcresults` and confirm these files exist:

```text
build/visuals/01-onboarding.png
build/visuals/02-today.png
build/visuals/qingjian-launch.mp4
```

- [ ] **Step 3: Report the run URL and download instructions**

Provide the user with the GitHub Actions run URL and explain: open the run, scroll to Artifacts, download `qingjian-xcresults`, then open the PNG/MP4 locally.
