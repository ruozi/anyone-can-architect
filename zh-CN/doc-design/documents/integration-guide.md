# 文档设计：integration-guide

## 1 文档定位

从接入方视角，指导接入和使用本产品提供的能力，并验证使用结果
接入方无需阅读内部设计文档就能完成手册所支持的场景

接口契约依据 [interface](interface.md)
制品取得与安装依据 [distribution](distribution.md)

## 2 文档结构

开头交代适用对象、平台与版本范围

第一章说明接入所需的环境，以及安装、认证和配置步骤

从第二章起，按接入形态组织使用内容
- SDK 围绕接入流程展开，再描述接入后的使用场景
- API 按用户业务场景分章，组合完成该场景所需的接口

使用内容按[层层深入](../../skills/references/drill-down.md)展开
每个场景说明适用条件、操作步骤、完成结果与失败后的处理
各场景说明必需与可选的接入条件

使用内容之后设置“调试与验证”章节，说明整体接入的检查方式与异常定位方法
按需设置“FAQ”章节，说明常见问题的适用条件、处理方法与反馈方式

结构示意：

```text
## 1 环境与配置
## 2 <接入流程或使用场景>
### 2.1 <具体内容>
### 2.2 <具体内容>
## 3 <使用场景>
…
## N 调试与验证
## N+1 FAQ              按需
```

## 3 行文步骤

1. 确定接入方、适用范围与手册支持的使用场景
   - 按接口契约选择各使用场景所需接口与调用约束，不要求覆盖全部接口
   - 按 [§2](#2-文档结构)确定使用内容的组织方式
2. 编写环境与配置
   - 说明接入环境、依赖与兼容要求
   - 按操作顺序说明制品取得、安装、认证与配置，并提供完成后的确认方式
   - 凭据与用户专属值说明取得方式和配置位置，示例从配置读取
3. 展开接入流程与使用场景
   - 可用代码表达的接入场景：以可复制运行的代码为主体，完整写出调用顺序、订阅与解绑、回调处理、重试或重复操作处理及生命周期管理
   - 参数用途、调用条件与语句自身无法表达的约束就近写入代码注释，不注释显然的语法
   - 正文只写代码之外必需的操作与完成结果，如文件放置、挂载对象、编辑器配置及外部验证结果，不复述代码已表达的调用与参数
   - 局部代码片段标明放入完整示例的位置及必需配套代码，不使用未定义的辅助方法或空实现冒充可复制代码
4. 补充调试与验证，以及所需 FAQ
   - 定义整体接入的检查步骤与通过条件
   - 根据使用者可获得的错误、状态与日志提供定位和恢复方式，使用场景引用对应内容
   - 反馈说明联系渠道与需要提供的信息，不要求提供实际凭据值
5. 核对实际交付
   - 核对安装方式、版本条件与接口，验证示例可执行
   - 使用所需信息在手册或面向接入方的公开资料中可取得，不依赖内部设计文档

## 4 示例

### 4.1 SDK 接入

````markdown
# 报告 SDK 接入指南

面向 Linux 上使用 Python 3.11 的业务工程，支持生成并下载部门报告
使用发行方交付的 aca_report_sdk-2.0.0-py3-none-any.whl

## 1 环境与配置

1. 安装 Python 3.11，执行 `python3.11 --version` 确认版本
2. 在业务工程中执行 `python3.11 -m venv .venv`，再执行 `source .venv/bin/activate`
3. 将交付的 wheel 放入工程目录，执行 `python -m pip install ./aca_report_sdk-2.0.0-py3-none-any.whl`
4. 执行 `python -c "from aca_report_sdk import ReportClient"`，无报错表示安装完成
5. 向报告服务管理员申请测试端点与测试令牌，写入运行环境的 `REPORT_ENDPOINT` 和 `REPORT_TOKEN`
   - 端点用于连接测试报告服务，令牌须具备销售部门报告的生成与下载权限
   - 未取得配置时停止，不使用正式环境令牌试跑示例

在执行示例的同一 Bash 会话中配置，替换占位值为取得的测试配置

```bash
export REPORT_ENDPOINT='<测试端点>'
export REPORT_TOKEN='<测试令牌>'
```

## 2 接入并使用报告能力

### 2.1 生成并下载报告

创建业务工程中的 `report_example.py`，写入以下完整示例
本例服务同步生成报告，创建成功后即可下载

```python
import os
from pathlib import Path
from aca_report_sdk import ReportClient

client = ReportClient(
    endpoint=os.environ["REPORT_ENDPOINT"],
    token=os.environ["REPORT_TOKEN"],
)
report = client.create_report(
    start_date="2026-09-01",
    end_date="2026-09-30",
    department="sales",
)
print(f"已创建报告 {report.report_id}", flush=True)
content = client.download_report(report.report_id)
Path("sales-report.csv").write_bytes(content)
print(f"已下载报告 {report.report_id}，共 {len(content)} 字节")
```

执行 `python report_example.py`
成功后工程目录出现 sales-report.csv，控制台显示报告标识与文件字节数

创建失败时不继续下载，按 [§3](#3-调试与验证)检查环境与权限
创建成功而下载失败时，保留已返回的 report_id，只重新下载，不重复创建报告

### 2.2 在业务中调用

业务确认部门与日期范围后调用 create_report，保存返回的 report_id
用户下载已生成报告时，用保存的 report_id 调用 download_report
令牌对应的权限必须覆盖所选部门

## 3 调试与验证

| 检查动作 | 预期结果 | 异常处理 |
| --- | --- | --- |
| 导入 ReportClient | 无导入错误 | 确认使用 .venv，检查 wheel 是否安装成功 |
| 运行示例 | 返回报告标识并生成 CSV | 检查端点、令牌及部门权限 |
| 打开 CSV | 数据属于 sales，日期均在所选范围内 | 保留 report_id，联系报告服务管理员核查 |

## 4 FAQ

**提示缺少 REPORT_TOKEN 怎么办？**

向管理员取得测试令牌，写入运行环境后重新执行
不要将令牌直接写入示例源码

**创建成功但下载失败，是否需要重新创建？**

不需要，保存 report_id，确认网络与下载权限后重新下载

仍无法处理时，向管理员提供 SDK 版本、report_id、错误信息与发生时间
不提供令牌值
````

### 4.2 API 使用场景

````markdown
# 报告 API 使用指南

面向通过 HTTP 使用报告服务的业务工程，支持生成报告与下载已有报告两个场景
只需要下载已有报告时，取得报告标识与访问权限后直接使用 [§3](#3-下载已有报告)

## 1 环境与配置

准备 Bash、curl 与 Python 3
向报告服务管理员取得测试端点与令牌，分别配置为 REPORT_ENDPOINT 与 REPORT_TOKEN
端点配置为服务根地址，不含末尾斜杠
下载已有报告时，向报告持有人取得 report_id，并配置为 REPORT_ID

在执行后续命令的同一 Bash 会话中配置，替换占位值为取得的测试配置

```bash
export REPORT_ENDPOINT='<测试端点>'
export REPORT_TOKEN='<测试令牌>'
```

直接下载已有报告时，再配置其标识

```bash
export REPORT_ID='<已有报告标识>'
```

## 2 生成报告

测试令牌须具备 sales 部门报告的生成权限
在同一 Bash 会话中执行以下命令

```bash
REQUEST_ID=$(python3 -c 'import uuid; print(uuid.uuid4())')
RESPONSE_FILE=$(mktemp)
curl --fail-with-body "$REPORT_ENDPOINT/reports" \
  -H "Authorization: Bearer $REPORT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $REQUEST_ID" \
  --data '{"department":"sales","start_date":"2026-09-01","end_date":"2026-09-30"}' \
  --output "$RESPONSE_FILE"
```

成功响应为 201，JSON 包含 report_id 与 status，status 为 ready
仅在 curl 成功退出时，执行以下命令读取标识并删除临时响应文件

```bash
REPORT_ID=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["report_id"])' "$RESPONSE_FILE")
rm "$RESPONSE_FILE"
```

网络中断且结果未知时，保留 REQUEST_ID，使用相同请求参数与幂等键重试，不重新生成幂等键
响应明确失败时，按 [§4](#4-调试与验证)排查，不进入下载步骤

## 3 下载已有报告

REPORT_ID 必须是已生成报告的标识，令牌须具备其所属部门的下载权限

```bash
curl --fail-with-body "$REPORT_ENDPOINT/reports/$REPORT_ID/file" \
  -H "Authorization: Bearer $REPORT_TOKEN" \
  --output sales-report.csv
```

成功响应为 200，文件为 CSV
失败响应可能写入同名文件，只有 curl 成功退出时才将其作为报告使用
下载失败时保留 REPORT_ID，修正网络或权限后重试

## 4 调试与验证

| 检查动作 | 预期结果 | 异常处理 |
| --- | --- | --- |
| 生成报告 | 201，status 为 ready，返回 report_id | 401 检查令牌，403 核对部门权限 |
| 下载报告 | 200，CSV 数据属于所选部门与日期范围 | 检查 REPORT_ID、下载权限与错误响应 |

## 5 FAQ

**已有报告，还需要先调用生成接口吗？**

不需要，取得报告标识与下载权限后，按 [§3](#3-下载已有报告)下载

**如何反馈失败请求？**

向报告服务管理员提供请求路径、响应状态码、错误信息、发生时间与请求标识
不提供 Authorization 头或令牌值
````

## 5 检查条件

- [ ] 适用对象、平台、版本范围与支持的场景已交代
- [ ] 结构符合接入形态，使用内容按流程或业务场景组织
- [ ] 环境、依赖、安装、认证与配置按实际顺序说明，所需信息有取得方式
- [ ] 场景所需能力完整，适用条件、操作步骤、完成结果与失败后的处理已定义
- [ ] 调用方式与接口契约一致，可用代码表达的场景以可复制运行的代码为主体，必需接线、回调、解绑、重试及重复操作均在代码中实现
- [ ] 参数用途、调用条件与语句自身无法表达的约束就近写入代码注释，正文没有复述代码已表达的调用与参数
- [ ] 示例可按所述步骤执行，依赖与参数替换位置齐全，局部代码片段标明放入完整示例的位置及必需配套代码
- [ ] 整体验证有可执行动作与可观察结果，异常有定位或反馈方式
- [ ] 手册与实际制品、接口及随包资料一致，不依赖内部设计文档
- [ ] 没有实际凭据值，用户专属配置有来源与使用位置
