import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { StoreHelper, Bill, TABLE_NAME, EditParams } from './StoreHelper';

// Chapter 24 §7 (list part): accounting list + keyword filter + delete + jump to edit.
@Entry
@Component
struct BillListDemo {
  private helper: StoreHelper = new StoreHelper();
  @State bills: Bill[] = [];
  @State keyword: string = '';
  @State onlyExpense: boolean = false;

  aboutToAppear(): void {
    const context = getContext(this) as common.Context;
    this.helper.init(context).then(() => {
      this.refresh();
    });
  }

  // Reload list applying current filters (keyword LIKE category, optional only-expense).
  async refresh(): Promise<void> {
    const p = new relationalStore.RdbPredicates(TABLE_NAME);
    p.orderByDesc('createTime');
    if (this.keyword.trim().length > 0) {
      p.like('category', '%' + this.keyword + '%');
    }
    if (this.onlyExpense) {
      p.equalTo('type', 0);
    }
    this.bills = await this.helper.queryBills(p);
  }

  async onDelete(id: number): Promise<void> {
    await this.helper.deleteBill(id);
    await this.refresh();
  }

  build() {
    Column({ space: 12 }) {
      Text('个人记账本 · 列表')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      TextInput({ text: this.keyword, placeholder: '按分类筛选，如 餐饮' })
        .width('90%')
        .onChange((v: string) => {
          this.keyword = v;
          this.refresh();
        })

      Row({ space: 12 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.onlyExpense })
          .onChange((v: boolean) => {
            this.onlyExpense = v;
            this.refresh();
          })
        Text('只看支出').fontSize(15)
        Blank()
        Button('+ 记一笔').onClick(() => {
          router.pushUrl({ url: 'pages/ch24/BillEditDemo' } as router.RouterOptions);
        })
      }
      .width('90%')

      List({ space: 8 }) {
        ForEach(this.bills, (bill: Bill) => {
          ListItem() {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(bill.category).fontSize(17).fontWeight(FontWeight.Medium)
                Text(bill.remark).fontSize(13).fontColor('#888')
              }
              .layoutWeight(1)

              Text((bill.type === 0 ? '-' : '+') + bill.amount.toFixed(2))
                .fontSize(17)
                .fontColor(bill.type === 0 ? '#E53935' : '#43A047')

              Button('改').onClick(() => {
                // pass editing id via a typed Record to satisfy ArkTS strict object-literal rule
                let params: EditParams = { billId: bill.id! };
                router.pushUrl({ url: 'pages/ch24/BillEditDemo', params: params } as router.RouterOptions);
              })
              Button('删').onClick(() => this.onDelete(bill.id!))
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
        }, (bill: Bill) => bill.id?.toString() ?? '0')
      }
      .width('90%')
      .layoutWeight(1)

      Button('返回').width('90%').onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
