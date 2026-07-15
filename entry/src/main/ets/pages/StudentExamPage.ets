import { ApiClient } from '../services/ApiClient';
import { ExamListItem, SemesterOption, UserInfo } from '../models/ApiModels';

@Component
export struct StudentExamPage {
  @Prop user: UserInfo;
  @Link page: number;
  @State exams: ExamListItem[] = [];
  @State semesters: SemesterOption[] = [];
  @State keyword: string = '';
  @State semesterId: number = 0;
  @State selected: ExamListItem | null = null;
  @State detailVisible: boolean = false;
  @State loading: boolean = false;
  @State errorText: string = '';

  aboutToAppear(): void { void this.initialize(); }

  private classGroupId(): number { return this.user.student?.classGroupId ?? 0; }

  private async initialize(): Promise<void> {
    try { this.semesters = await ApiClient.getSemesterOptions(); } catch (_) {}
    await this.load();
  }

  private async load(): Promise<void> {
    const classGroupId = this.classGroupId();
    if (classGroupId <= 0) { this.errorText = '当前账号未关联班级，暂时无法查询考试安排'; return; }
    this.loading = true;
    this.errorText = '';
    try { this.exams = (await ApiClient.getExams(1, 100, this.keyword, this.semesterId > 0 ? this.semesterId : undefined, classGroupId)).items; }
    catch (error) { this.errorText = error instanceof Error ? error.message : '加载考试安排失败'; }
    finally { this.loading = false; }
  }

  private semesterLabel(): string {
    const item = this.semesters.find((v: SemesterOption) => v.id === this.semesterId);
    return item ? item.label : '全部学期';
  }

  private selectNextSemester(): void {
    if (this.semesters.length === 0) return;
    const index = this.semesters.findIndex((v: SemesterOption) => v.id === this.semesterId);
    this.semesterId = index < 0 || index >= this.semesters.length - 1 ? 0 : this.semesters[index + 1].id;
    void this.load();
  }

  private async openDetail(item: ExamListItem): Promise<void> {
    try { this.selected = await ApiClient.getExam(item.id); } catch (_) { this.selected = item; }
    this.detailVisible = true;
  }

  private showToast(message: string): void { try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {} }

  private formatTime(value: string): string {
    const matched = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/);
    if (matched === null) return value;
    return `${matched[1]}年${matched[2]}月${matched[3]}日${matched[4]}时${matched[5]}分`;
  }

  @Builder
  private examRow(item: ExamListItem) {
    Column({ space: 7 }) {
      Row() { Column({ space: 4 }) { Text(item.courseName ?? `课程 ${item.courseId}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#17324D'); Text(`${item.classGroupName ?? '本班'} · ${item.classroomRoomNo ?? '待定教室'}`).fontSize(12).fontColor('#718096') }.layoutWeight(1).alignItems(HorizontalAlign.Start); Text('考试').fontSize(11).fontColor('#176B87').backgroundColor('#E4F2F5').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9) }
      Text(`开始：${this.formatTime(item.startTime)}`).fontSize(13).fontColor('#516B80').width('100%')
      Text(`结束：${this.formatTime(item.endTime)}`).fontSize(13).fontColor('#516B80').width('100%')
      Text(`监考教师：${item.invigilatorName ?? '待安排'}`).fontSize(12).fontColor('#8999A4').width('100%')
      Button('查看详情').width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { void this.openDetail(item); })
    }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
  }

  @Builder
  private detailDialog() {
    if (this.detailVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Column({ space: 12 }) {
          Row() { Text('考试详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text('×').fontSize(26).fontColor('#718096').onClick(() => this.detailVisible = false) }.width('100%')
          Text(`课程：${this.selected.courseName ?? this.selected.courseId}`).fontSize(15).fontColor('#17324D').width('100%')
          Text(`班级：${this.selected.classGroupName ?? '本班'}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`考场：${this.selected.classroomRoomNo ?? '待定'}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`开始时间：${this.formatTime(this.selected.startTime)}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`结束时间：${this.formatTime(this.selected.endTime)}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`监考教师：${this.selected.invigilatorName ?? '待安排'}`).fontSize(14).fontColor('#516B80').width('100%')
          Button('关闭').width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.detailVisible = false)
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() { Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0); Text('考试查询').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text(`${this.exams.length} 条`).fontSize(13).fontColor('#718096') }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Text(`当前班级：${this.user.student?.classGroup?.name ?? '已关联班级'}`).fontSize(13).fontColor('#718096').width('100%').padding({ left: 20, right: 20, bottom: 10 })
        Row({ space: 8 }) { TextInput({ placeholder: '搜索课程、考场或监考教师', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10).onChange((v: string) => this.keyword = v).onSubmit(() => { void this.load(); }); Button('搜索').height(40).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.load(); }); Button(this.semesterLabel()).height(40).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.selectNextSemester()) }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
        if (this.loading) { LoadingProgress().color('#176B87').layoutWeight(1) }
        else if (this.errorText.length > 0) { Column({ space: 10 }) { Text(this.errorText).fontSize(14).fontColor('#B04A4A').textAlign(TextAlign.Center); Button('重新加载').onClick(() => { void this.load(); }) }.layoutWeight(1).justifyContent(FlexAlign.Center) }
        else if (this.exams.length === 0) { Column({ space: 8 }) { Text('暂无考试安排').fontSize(16).fontColor('#516B80'); Text('当前班级暂未发布考试信息').fontSize(13).fontColor('#8999A4') }.layoutWeight(1).justifyContent(FlexAlign.Center) }
        else { List() { ForEach(this.exams, (item: ExamListItem) => { ListItem() { this.examRow(item) } }, (item: ExamListItem) => `${item.id}`) }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 }) }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.detailDialog()
    }.width('100%').height('100%')
  }
}
