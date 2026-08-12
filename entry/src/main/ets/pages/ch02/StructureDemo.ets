// Chapter 2 demo: visualize the key directories and config files of a Stage-model project.
// Named interface for the item list (ArkTS forbids inline object-literal types & untyped literals).
interface ProjectItem {
  name: string
  duty: string
}

@Entry
@Component
struct StructureDemo {
  private items: ProjectItem[] = [
    { name: 'AppScope', duty: '全局公共资源与 App 全局配置（app.json5 / 全局 string、media）' },
    { name: 'entry', duty: '主模块：src 源码 + resources 资源 + 配置文件' },
    { name: 'main_pages.json', duty: '页面路由清单：声明本包内有哪些 page（路径数组）' },
    { name: 'module.json5', duty: '当前 UIAbility 配置：name / srcEntry / abilities / deviceTypes 等' },
    { name: 'build-profile.json5', duty: '编译构建设置：apiType / targets / runtimeOS' },
    { name: 'oh-package.json5', duty: '模块级依赖与元信息（name / dependencies 等）' }
  ]

  build() {
    Column({ space: 12 }) {
      Text('Stage 工程关键结构')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.items, (it: ProjectItem) => {
            Column({ space: 4 }) {
              Text(it.name).fontSize(18).fontWeight(FontWeight.Medium)
              Text(it.duty).fontSize(13).fontColor('#666')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          })
        }
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
