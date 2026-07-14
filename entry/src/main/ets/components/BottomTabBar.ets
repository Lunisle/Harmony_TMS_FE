@Component
export struct BottomTabBar {
  @Link selectedIndex: number;

  @Builder
  private tabItem(index: number, icon: string, label: string) {
    Column({ space: 3 }) {
      Text(icon)
        .fontSize(23)
        .fontColor(this.selectedIndex === index ? '#176B87' : '#91A0AD')
      Text(label)
        .fontSize(12)
        .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selectedIndex === index ? '#176B87' : '#718096')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 10, bottom: 9 })
    .onClick(() => this.selectedIndex = index)
  }

  build() {
    Row() {
      this.tabItem(0, '⌂', '首页')
      this.tabItem(1, '▦', '工作台')
      this.tabItem(2, '◉', '我的')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({ radius: 14, color: '#16000000', offsetY: -3 })
  }
}
