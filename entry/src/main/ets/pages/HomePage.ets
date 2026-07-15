import { UserInfo } from '../models/ApiModels';
import { STATIC_ANNOUNCEMENTS } from '../models/AnnouncementModels';

@Component
export struct HomePage {
  @Prop user: UserInfo;
  @Link announcementId: number;

  @Builder
  private banner(image: Resource, title: string, subtitle: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(image)
        .width('100%')
        .height(210)
        .objectFit(ImageFit.Cover)
      Column({ space: 6 }) {
        Text(title)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(subtitle)
          .fontSize(13)
          .fontColor('#E8F4F7')
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 36, bottom: 18 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#C217324D', 0.0], ['#0017324D', 1.0]]
      })
    }
    .width('100%')
    .height(210)
    .borderRadius(18)
    .clip(true)
  }

  @Builder
  private notice(id: number, title: string, date: string, isFirst: boolean) {
    Row({ space: 12 }) {
      Column()
        .width(5)
        .height(22)
        .borderRadius(3)
        .backgroundColor(isFirst ? '#176B87' : '#B8C5CD')
      Text(title)
        .fontSize(15)
        .fontColor('#29445A')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      Text(date)
        .fontSize(12)
        .fontColor('#8A9AA8')
    }
    .width('100%')
    .padding({ top: 13, bottom: 13 })
    .border({ width: { bottom: 1 }, color: '#EDF1F3' })
    .onClick(() => this.announcementId = id)
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Row() {
          Column({ space: 4 }) {
            Text(`你好，${this.user.student?.name ?? this.user.username}`)
              .fontSize(25)
              .fontWeight(FontWeight.Bold)
              .fontColor('#17324D')
            Text('欢迎进入教学过程管理系统')
              .fontSize(13)
              .fontColor('#718096')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Image($r('app.media.uestc_logo'))
            .width(118)
            .height(42)
            .backgroundColor('#176B87')
            .borderRadius(12)
            .objectFit(ImageFit.Contain)
            .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        }
        .width('100%')

        Swiper() {
          this.banner($r('app.media.banner_classroom'), '教学协同，学习同行', '让每一次教学安排更清晰')
          this.banner($r('app.media.banner_campus'), '校园服务，触手可及', '及时关注教学过程与服务动态')
          this.banner($r('app.media.banner_library'), '沉浸学习，稳步成长', '记录你的每一段学习旅程')
        }
        .width('100%')
        .height(210)
        .indicator(true)
        .autoPlay(true)
        .interval(4500)
        .loop(true)

        Column({ space: 2 }) {
          Text('最新公告')
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontColor('#17324D')
            .width('100%')
          Column() {
            this.notice(STATIC_ANNOUNCEMENTS[0].id, STATIC_ANNOUNCEMENTS[0].title, STATIC_ANNOUNCEMENTS[0].date, true)
            this.notice(STATIC_ANNOUNCEMENTS[1].id, STATIC_ANNOUNCEMENTS[1].title, STATIC_ANNOUNCEMENTS[1].date, false)
            this.notice(STATIC_ANNOUNCEMENTS[2].id, STATIC_ANNOUNCEMENTS[2].title, STATIC_ANNOUNCEMENTS[2].date, false)
            this.notice(STATIC_ANNOUNCEMENTS[3].id, STATIC_ANNOUNCEMENTS[3].title, STATIC_ANNOUNCEMENTS[3].date, false)
          }
          .width('100%')
          .margin({ top: 8 })
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 12, color: '#10000000', offsetY: 4 })
          Row() {
            Text('查看全部公告').fontSize(13).fontColor('#176B87').layoutWeight(1)
            Text('›').fontSize(20).fontColor('#176B87')
          }.width('100%').padding({ top: 10, left: 16, right: 16 }).onClick(() => this.announcementId = -2)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 20 })
    }
    .layoutWeight(1)
    .width('100%')
  }
}
