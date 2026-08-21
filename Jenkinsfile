// Jenkinsfile —— TutorialDemo 鸿蒙自动构建流水线
// 部署位置: 仓库根目录 (与 hvigorw.bat 同层)
// 适用: Jenkins 2.x (LTS) + Pipeline 插件 + 自托管 Windows 构建机 (已装 DevEco / 鸿蒙 SDK / Node18 / ohpm)
//
// 说明:
//  - 本工程已补齐 hvigorw / hvigorw.bat / hvigor/hvigor-wrapper.js (CLI 构建依赖)
//  - build-profile.json5 的 signingConfigs 当前为空, 真机/上架包必须补签名(见下方 environment 注释)
//  - 若暂不配置签名凭据, 请注释掉 environment 块, 先打通 debug 无签名构建流程

pipeline {
    agent { label 'windows-harmonyos' }   // 在打此标签的自托管 Windows 节点运行

    // ===== 手动"新建打包任务"时可选的参数 =====
    parameters {
        string(name: 'GIT_BRANCH', defaultValue: 'master', description: '要拉取的 Git 分支 (主分支是 master)')
        choice(name: 'PRODUCT', choices: ['default'], description: '构建 product flavor (对应 build-profile.json5 的 products)')
        choice(name: 'BUILD_MODE', choices: ['debug', 'release'], description: '构建模式: debug=测试包, release=上架包')
        booleanParam(name: 'BUILD_APP', defaultValue: false, description: '是否额外构建 APP 整包 (release 才有意义, 用于上架)')
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()   // 同一任务排队, 避免单台构建机资源争抢
        cleanWs()                    // 每次构建前清理工作区, 保证拉的是干净最新代码
    }

    // ===== 触发方式 =====
    triggers {
        // 方案A (推荐本地用, 无需公网): 每5分钟轮询 GitHub, 有更新自动构建
        pollSCM('H/5 * * * *')
        // 方案B (实时): 需安装 GitHub 插件 + 在 GitHub 仓库配 Webhook 指向 Jenkins, 且 Jenkins 需公网可达
        // githubPush()
    }

    environment {
        // 签名密码从 Jenkins 凭据注入, 绝不进仓库明文
        // 先在 Jenkins → 凭据 添加两条 Secret text:
        //   ID: harmony-keystore-password  (storePassword)
        //   ID: harmony-keyalias-password  (keyAlias / keyPassword)
        // 若暂时不配, 注释掉下面两行, 仅调试无签名 debug 构建
        KEYSTORE_PWD = credentials('harmony-keystore-password')
        KEYALIAS_PWD = credentials('harmony-keyalias-password')
    }

    stages {
        stage('环境自检') {
            steps {
                bat '''
                    echo [ENV] Node: & node -v
                    echo [ENV] ohpm: & where ohpm
                    echo [ENV] hvigorw: & where hvigorw.bat
                '''
            }
        }

        stage('拉取最新代码') {
            steps {
                // 公开仓直接拉; 私有仓在 credentialsId 传 GitHub token
                git branch: "${params.GIT_BRANCH}", url: 'https://github.com/Mrshenyan/TutorialDemo.git'
                // 私有仓示例:
                // git branch: "${params.GIT_BRANCH}", url: 'https://github.com/Mrshenyan/TutorialDemo.git', credentialsId: 'github-token'
            }
        }

        stage('安装依赖 (ohpm)') {
            steps {
                bat 'ohpm install'
            }
        }

        stage('Clean') {
            steps {
                bat 'hvigorw.bat clean --no-daemon'
            }
        }

        stage('构建 HAP') {
            steps {
                bat "hvigorw.bat assembleHap -p product=${params.PRODUCT} -p buildMode=${params.BUILD_MODE} --no-daemon"
            }
        }

        stage('构建 APP (release 整包)') {
            when {
                allOf {
                    expression { params.BUILD_APP }
                    expression { params.BUILD_MODE == 'release' }
                }
            }
            steps {
                bat "hvigorw.bat assembleApp -p product=${params.PRODUCT} --no-daemon"
            }
        }
    }

    post {
        success {
            // 归档产物, Jenkins 构建页可直接下载 HAP/APP
            archiveArtifacts artifacts: '**/build/**/*.hap, **/build/**/*.app', fingerprint: true
            echo '构建成功, 产物已归档到本次构建页面'
            // 可扩展: 企微/邮件通知、上传蒲公英、分发内网文件服务
        }
        failure {
            echo '构建失败, 请查看上方日志 (常见: SDK 缺失 / 签名未配 / Node 版本不对)'
        }
    }
}
