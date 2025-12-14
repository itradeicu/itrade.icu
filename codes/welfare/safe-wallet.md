
# 安全钱包源码


---

本文由 [https://itrade.icu](https://www.itrade.icu) 量化交易实验室出品。
本项目提供一个安全的 **加密钱包创建与解密工具**，方便用户生成自己的区块链钱包，同时保证私钥和密码的加密存储。

## 介绍
* **加密钱包创建**：通过 `create.js` 可以生成钱包，并自动生成加密的私钥、解密密钥和钱包密码。支持随机生成或自定义密码。
* **钱包解密**：通过 `unravel.js` 可以解密加密的钱包文件，安全地查看和使用钱包私钥。
* **安全管理**：提供多种钱包备份与保存建议，防止因私钥丢失造成资产损失。
* **依赖管理**：支持 `npm`、`pnpm` 或 `yarn` 安装依赖，操作简单。

该工具适合个人使用或学习区块链钱包加密解密机制，同时强调操作安全，建议在断网环境下进行解密操作，确保私钥安全。




## 加密解密
+ create.js 加密钱包
+ unravel.js 钱包解密

## 依赖下载
任选一种自己常用的下载方式，推荐使用`pnpm`方式下载
```bash
npm install 
pnpm install 
yarn install 
```
---
## 创建钱包
运行下面命令执行创建钱包
```bash
node create.js
```

### 可选的两种方式创建钱包
1. 使用随机密码来创建自己的钱包
```bash
(base) loser@loserdeMacBook-Pro safe-wallet % node create.js 
✔ 输入自定义KEY值，输入R为随机创建. · r
✔ 输入自定义IV值，输入R为随机创建. · r
✔ 输入自定义PASSWORD值，输入R为随机创建. · r
{ key: 'sBIIY)R?(3b&', iv: 'D.Tw%<AOuYff', password: 'UL6GT4H+9q*6' }
钱包创建成功：0xC640DbfE7CE8B30497276BF72604f0A4b78A5d0B
```
---

2. 使用自定义密码来创建自己的钱包
```bash
(base) loser@loserdeMacBook-Pro safe-wallet % node create.js
✔ 输入自定义KEY值，输入R为随机创建. · 123123
✔ 输入自定义IV值，输入R为随机创建. · 123123
✔ 输入自定义PASSWORD值，输入R为随机创建. · 123123
{ key: '123123', iv: '123123', password: '123123' }
钱包创建成功：0x256823E8DD9EE91B4ac9C259B350C85244bF2c97
```
### 创建成功查看
创建成功后，会在`./address`下生成三个文件，分别为`*.key.iv`、`*.password`、`*.wallet`，分别对应加密钱包私钥、解密密钥、钱包密码。
![alt text](/codes/welfare/safe-wallet_1.png)
### 安全建议
建议多备份几份钱包私钥，防止丢失，钱包私钥丢失将无法找回钱包。
1. 建议使用[腾讯云oss](https://buy.cloud.tencent.com/cos)(3.9¥/5年)
保存，或者多个地方保存，防止丢失。
![alt text](/codes/welfare/safe-wallet_2.png)
2. 网盘保存，如百度网盘、阿里云盘等。
3. 移动硬盘保存，如西部数据、金士顿等。
4. 安全提醒：建议以上都不要使用唯一的保存方式，而是一份保存多个地方，防治某个丢失造成资产损失。

## 解密钱包
运行下面命令执行解密钱包
1. 把对应的钱包填写`unravel.js`到对应的变量中。
```bash
# 根据钱包的后缀名，填写对应的文件名
const key_iv = ""
const password = ""
const wallet = ""
```
2. 运行下面命令执行解密钱包
```bash
node unravel.js
```
> 即可看到自己的钱包。
![alt text](/codes/welfare/safe-wallet_3.png)
### 安全建议
1. 运行之前先下载依赖。
2. `断网之后运行`解密钱包，防止被黑客获取到你的钱包私钥。
3. 分段复制钱包私钥，防止被黑客获取到你的钱包私钥。

## 安全钱包源码
<Articles />