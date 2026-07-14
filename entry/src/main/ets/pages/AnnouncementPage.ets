import { Announcement, STATIC_ANNOUNCEMENTS } from '../models/AnnouncementModels';

@Component
export struct AnnouncementPage {
  @Link announcementId: number;

  private currentAnnouncement(): Announcement | null {
    for (let index = 0; index < STATIC_ANNOUNCEMENTS.length; index++) {
      if (STATIC_ANNOUNCEMENTS[index].id === this.announcementId) return STATIC_ANNOUNCEMENTS[index];
    }
    return null;
  }

  @Builder
  private header(title: string) {
    Row() {
      Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.announcementId = -1)
      Text(title).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
    }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 12 })
  }

  @Builder
  private listView() {
    Column({ space: 12 }) {
      this.header('公告通知')
      ForEach(STATIC_ANNOUNCEMENTS, (item: Announcement) => {
        Column({ space: 8 }) {
          Row() { Text(item.category).fontSize(12).fontColor('#176B87').layoutWeight(1); Text(item.date).fontSize(12).fontColor('#8A9AA8') }
          Text(item.title).fontSize(17).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(item.summary).fontSize(13).fontColor('#718096').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 8, color: '#10000000', offsetY: 3 }).onClick(() => this.announcementId = item.id)
      })
    }.width('100%').padding({ left: 20, right: 20, bottom: 24 })
  }

  @Builder
  private detailView(item: Announcement) {
    Column({ space: 16 }) {
      this.header('公告详情')
      Column({ space: 14 }) {
        Row() { Text(item.category).fontSize(12).fontColor('#176B87').layoutWeight(1); Text(item.date).fontSize(12).fontColor('#8A9AA8') }
        Text(item.title).fontSize(23).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
        Divider().color('#DCE9ED')
        Text(item.content).fontSize(16).fontColor('#516B80').lineHeight(28).width('100%')
      }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(18)
    }.width('100%').padding({ left: 20, right: 20, bottom: 24 })
  }

  build() {
    Scroll() {
      if (this.announcementId >= 0) {
        if (this.announcementId === STATIC_ANNOUNCEMENTS[0].id) {
          this.detailView(STATIC_ANNOUNCEMENTS[0]);
        } else if (this.announcementId === STATIC_ANNOUNCEMENTS[1].id) {
          this.detailView(STATIC_ANNOUNCEMENTS[1]);
        } else if (this.announcementId === STATIC_ANNOUNCEMENTS[2].id) {
          this.detailView(STATIC_ANNOUNCEMENTS[2]);
        }
      } else {
        this.listView();
      }
    }.width('100%').height('100%').backgroundColor('#EDF5F7')
  }
}
