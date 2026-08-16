import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { StoreHelper, Bill, TABLE_NAME } from './StoreHelper';

// Chapter 24 §7 (edit part): add a new bill, or edit an existing one passed via router params.
@Entry
@Component
struct BillEditDemo {
  private helper: StoreHelper = new StoreHelper();
  @State editingId: number = -1;
  @State type: number = 0;        // 0 expense, 1 income
  @State category: string = '餐饮';
  @State amount: string = '';
  @State remark: string = '';
  @State log: string = '填写后点保存';

  aboutToAppear(): void {
    const context = getContext(this) as common.Context;
    this.helper.init(context).then(() => {
      const params = router.getParams() as Record<string, Object> | undefined;
      if (params && params['billId'] !== undefined) {
        const id = params['billId'] as number;
        this.editingId = id;
        this.loadBill(id);
      }
    });
  }

  // Load the row to edit into the form fields.
  async loadBill(id: number): Promise<void> {
    const p = new relationalStore.RdbPredicates(TABLE_NAME);
    p.equalTo('id', id);
    const list = await this.helper.queryBills(p);
    if (list.length > 0) {
      const b = list[0];
      this.type = b.type;
      this.category = b.category;
      this.amount = b.amount.toString();
      this.remark = b.remark;
      this.log = '编辑中';
    }
  }

  async onSave(): Promise<void> {
    const amt = parseFloat(this.amount);
    if (isNaN(amt) || this.category.trim().length === 0) {
      this.log = '金额或分类不能为空';
      return;
    }
    const bill: Bill = {
      type: this.type,
      category: this.category.trim(),
      amount: amt,
      remark: this.remark,
      createTime: Date.now()
    };
    if (this.editingId >= 0) {
      bill.id = this.editingId;
      await this.helper.updateBill(bill);
      this.log = '已更新';
    } else {
      await this.helper.insertBill(bill);
      this.log = '已新增';
    }
    router.back();
  }

  build() {
    Column({ space: 12 }) {
      Text(this.editingId >= 0 ? '编辑一笔' : '记一笔')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })

      Row({ space: 12 }) {
        Text('类型').fontSize(16)
        Radio({ value: 'expense', group: 'type' }).checked(this.type === 0).onChange(() => { this.type = 0; })
        Text('支出')
        Radio({ value: 'income', group: 'type' }).checked(this.type === 1).onChange(() => { this.type = 1; })
        Text('收入')
      }
      .width('90%')

      TextInput({ text: this.category, placeholder: '分类，如 餐饮/交通' })
        .width('90%')
        .onChange((v: string) => { this.category = v; })

      TextInput({ text: this.amount, placeholder: '金额' })
        .width('90%')
        .onChange((v: string) => { this.amount = v; })

      TextInput({ text: this.remark, placeholder: '备注' })
        .width('90%')
        .onChange((v: string) => { this.remark = v; })

      Button('保存').width('90%').onClick(() => this.onSave())
      Text(this.log).fontSize(14).fontColor('#999')
      Button('返回').width('90%').onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
