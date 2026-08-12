// Chapter 19 §七: Picker dialogs (date / time / text) — static .show().

@Entry
@Component
struct PickerDemo {
  build() {
    Column({ space: 16 }) {
      Button('日期选择')
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date('2000-01-01'),
            end: new Date('2100-12-31'),
            selected: new Date(),
            onAccept: (value: DatePickerResult) => {
              console.log(`选了：${value.year}-${(value.month ?? 0) + 1}-${value.day}`)
            },
            onCancel: () => {},
            onChange: (value: DatePickerResult) => {}
          })
        })

      Button('时间选择')
        .onClick(() => {
          TimePickerDialog.show({
            selected: new Date(),
            onAccept: (value: TimePickerResult) => {
              console.log(`选了：${value.hour}:${value.minute}`)
            },
            onCancel: () => {}
          })
        })

      Button('文本选择')
        .onClick(() => {
          TextPickerDialog.show({
            range: ['北京', '上海', '广州', '深圳'],
            selected: 0,
            onAccept: (value: TextPickerResult) => {
              console.log(`选了：${value.value}`)
            },
            onCancel: () => {}
          })
        })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}
