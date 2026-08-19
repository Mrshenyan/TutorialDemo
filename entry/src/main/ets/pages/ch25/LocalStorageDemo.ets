import { router } from '@kit.ArkUI';

// Chapter 25 §3: LocalStorage is page-scoped (NOT global).
// Create an instance and bind it to the @Entry; descendant components
// automatically share that same instance via @LocalStorageLink.

// Create this page's LocalStorage instance.
// The init object must correspond to a declared interface (arkts-no-untyped-obj-literals).
interface PageInit {
  'page.count': number;
  'page.tag': string;
}
let pageInit: PageInit = { 'page.count': 0, 'page.tag': '局部' };
let pageStore: LocalStorage = new LocalStorage(pageInit);

@Entry(pageStore)
@Component
struct LocalStorageDemo {
  @LocalStorageLink('page.count') count: number = 0;
  @LocalStorageProp('page.tag') tag: string = '局部';

  build() {
    Column({ space: 16 }) {
      Text('LocalStorage：页面级状态')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Text('计数（双向，父子共享同一实例）：' + this.count)
        .fontSize(16)

      Button('+1').onClick(() => {
        this.count += 1;
      })

      // Child shares the SAME LocalStorage instance bound to @Entry.
      LocalChild()

      Text('LocalStorage 不是全局：跳走再回来 = 新实例，计数归零。\n对比 AppStorageDemo 的全局 key 不会重置。')
        .fontSize(12)
        .fontColor('#999')

      Button('返回').width('80%').margin({ top: 16 }).onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@Component
struct LocalChild {
  @LocalStorageLink('page.count') count: number = 0;

  build() {
    Column({ space: 8 }) {
      Text('子组件读到的计数：' + this.count)
        .fontSize(15)
      Text('（父子绑定同一 LocalStorage 实例，改父这里会同步）')
        .fontSize(12)
        .fontColor('#999')
    }
    .width('90%')
    .padding(12)
    .border({ width: 1, color: '#999' })
    .borderRadius(8)
  }
}
