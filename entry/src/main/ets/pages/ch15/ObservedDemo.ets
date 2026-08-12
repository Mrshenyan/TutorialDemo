// Chapter 15 §二-§四: @Observed + @ObjectLink for nested object observation.
// Rule of thumb: one layer of object = one layer of component + one @ObjectLink.

@Observed
class Address {
  city: string

  constructor(city: string) {
    this.city = city
  }
}

@Observed
class User {
  name: string
  address: Address

  constructor(name: string, city: string) {
    this.name = name
    this.address = new Address(city)
  }
}

// Inner component: receives the nested Address via @ObjectLink so it can
// observe changes to Address's own (first-layer) properties.
@Component
struct AddressView {
  @ObjectLink address: Address

  build() {
    Column() {
      Text(`城市: ${this.address.city}`)
        .margin({ top: 4, bottom: 8 })

      Button('改城市')
        .onClick(() => {
          this.address.city =
            this.address.city === '深圳' ? '上海' : '深圳'
        })
    }
  }
}

// Outer item: receives the User via @ObjectLink.
@Component
struct UserItem {
  @ObjectLink user: User

  build() {
    Column() {
      Text(`姓名: ${this.user.name}`)

      // Pass the nested object down to the next @ObjectLink layer.
      AddressView({ address: this.user.address })
    }
    .padding(12)
    .margin(8)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .width('90%')
  }
}

@Entry
@Component
struct UserPage {
  @State users: User[] = [
    new User('小明', '深圳'),
    new User('小红', '北京')
  ]

  build() {
    Column() {
      Text('用户列表（Observed + ObjectLink）')
        .fontSize(20)
        .margin(16)

      ForEach(this.users, (item: User) => {
        UserItem({ user: item })
      }, (item: User) => item.name)

      Button('父组件改第一个人的姓名')
        .margin(16)
        .onClick(() => {
          this.users[0].name =
            this.users[0].name === '小明' ? '阿明' : '小明'
        })
    }
    .width('100%')
    .height('100%')
  }
}
