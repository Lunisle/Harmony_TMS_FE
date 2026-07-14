import { ApiClient } from '../services/ApiClient';
import { CourseDetail } from '../models/ApiModels';

@Component
export struct CourseDetailPage {
  @Link page: number;
  @Link courseId: number;
  @State semesterIdText: string = '';
  @State detail: CourseDetail | null = null;
  @State loading: boolean = false;

  aboutToAppear(): void { void this.loadDetail(); }

  private async loadDetail(): Promise<void> {
    const semesterText = this.semesterIdText.trim();
    const semesterId = semesterText.length === 0 ? undefined : Number(semesterText);
    if (semesterId !== undefined && (!Number.isInteger(semesterId) || semesterId < 1)) { this.showToast('学期 ID 必须是正整数'); return; }
    this.loading = true;
    try { this.detail = await ApiClient.getCourseDetail(this.courseId, semesterId); }
    catch (error) { this.detail = null; this.showToast(error instanceof Error ? error.message : '加载课程详情失败'); }
    finally { this.loading = false; }
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {}
  }

  private backToCourseList(): void {
    this.page = 4;
  }

  @Builder
  private arrangementCard(title: string, count: number, description: string) {
    Row({ space: 12 }) {
      Column() { Text(`${count}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#176B87'); Text('条记录').fontSize(11).fontColor('#8999A4') }.width(62)
      Column({ space: 4 }) { Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#29445A'); Text(description).fontSize(12).fontColor('#718096') }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%').padding({ left: 15, right: 15, top: 12, bottom: 12 }).backgroundColor(Color.White)
  }

  build() {
    Column() {
      Row() { Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.backToCourseList()); Text('课程详情').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text('课程信息').fontSize(12).fontColor('#718096') }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
      Row({ space: 8 }) {
        Text(`课程 ID：${this.courseId}`).fontSize(14).fontColor('#516B80').layoutWeight(1)
        TextInput({ placeholder: '学期 ID', text: this.semesterIdText }).type(InputType.Number).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10).onChange((value: string) => this.semesterIdText = value)
        Button(this.loading ? '加载中' : '查询').enabled(!this.loading).height(42).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.loadDetail(); })
      }.width('100%').padding({ left: 20, right: 20, bottom: 12 })
      Scroll() {
        Column({ space: 0 }) {
          if (this.detail === null) {
            Text('').height(40)
          } else {
            Column({ space: 12 }) {
              Row() { Column({ space: 5 }) { Text(this.detail.name).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D'); Text(`${this.detail.code} · ${this.detail.credits} 学分`).fontSize(13).fontColor('#718096') }.layoutWeight(1).alignItems(HorizontalAlign.Start); Text(this.detail.courseType ?? '未分类').fontSize(12).fontColor('#176B87').backgroundColor('#E4F2F5').padding({ left: 9, right: 9, top: 5, bottom: 5 }).borderRadius(10) }
              Row({ space: 14 }) { Column({ space: 4 }) { Text('院系').fontSize(12).fontColor('#8999A4'); Text(this.detail.departmentName ?? this.detail.department?.name ?? '未设置').fontSize(14).fontColor('#29445A') }.layoutWeight(1).alignItems(HorizontalAlign.Start); Column({ space: 4 }) { Text('课程负责人').fontSize(12).fontColor('#8999A4'); Text(this.detail.directorName ?? this.detail.director?.name ?? '未设置').fontSize(14).fontColor('#29445A') }.layoutWeight(1).alignItems(HorizontalAlign.Start) }
              Row({ space: 14 }) { Text(`学期 ID：${this.semesterIdText || '全部'}`).fontSize(12).fontColor('#718096').layoutWeight(1); Text(`课程 ID：${this.detail.id}`).fontSize(12).fontColor('#718096').layoutWeight(1) }
            }.width('100%').padding(18).backgroundColor(Color.White).borderRadius(18).shadow({ radius: 8, color: '#10000000', offsetY: 2 })
            Text('关联安排').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#29445A').width('100%').margin({ top: 14, bottom: 8 })
            this.arrangementCard('考试安排', this.detail.arrangements.exams.length, '该课程关联的考试与监考信息')
            this.arrangementCard('调课申请', this.detail.arrangements.scheduleChanges.length, '该课程关联的调课记录')
            this.arrangementCard('教材征订', this.detail.arrangements.textbookOrders.length, '该课程关联的教材订单')
            this.arrangementCard('教学日志', this.detail.arrangements.teachingLogs.length, '该课程关联的教学过程记录')
          }
        }.width('100%').padding({ left: 20, right: 20, bottom: 24 })
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor('#EDF5F7')
  }
}
