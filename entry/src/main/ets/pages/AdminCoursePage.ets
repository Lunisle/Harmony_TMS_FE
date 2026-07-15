import { ApiClient } from '../services/ApiClient';
import { CourseSummary } from '../models/ApiModels';

@Component
export struct AdminCoursePage {
  @Link page: number;
  @Link selectedCourseId: number;
  @State courses: CourseSummary[] = [];
  @State keyword: string = '';
  @State loading: boolean = false;
  @State errorText: string = '';

  aboutToAppear(): void { void this.loadCourses(); }

  private async loadCourses(): Promise<void> {
    this.loading = true;
    this.errorText = '';
    try { this.courses = await ApiClient.getCourses(this.keyword); }
    catch (error) { this.errorText = error instanceof Error ? error.message : '加载课程列表失败'; }
    finally { this.loading = false; }
  }

  private openDetail(course: CourseSummary): void {
    this.selectedCourseId = course.id;
    this.page = 5;
  }

  @Builder
  private courseRow(course: CourseSummary) {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text(course.name).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#17324D').width('100%')
        Text(course.credits > 0 ? `${course.code} · ${course.credits} 学分` : course.code).fontSize(12).fontColor('#718096').width('100%')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Column({ space: 3 }) {
        Text(course.departmentName ?? '未设置院系').fontSize(12).fontColor('#516B80')
        Text(course.directorName ?? '未设置负责人').fontSize(12).fontColor('#718096')
      }.width(105).alignItems(HorizontalAlign.End)
      Text('详情').fontSize(13).fontColor('#176B87').width(48).textAlign(TextAlign.Center)
        .onClick(() => this.openDetail(course))
    }.width('100%').padding({ top: 14, bottom: 14, left: 10, right: 8 })
      .backgroundColor(Color.White).borderRadius(14).margin({ bottom: 10 })
      .onClick(() => this.openDetail(course))
  }

  build() {
    Column() {
      Row() {
        Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0)
        Text('课程管理').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
        Text(`${this.courses.length} 门`).fontSize(13).fontColor('#718096')
      }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索课程编号或名称', text: this.keyword }).layoutWeight(1).height(42)
          .backgroundColor(Color.White).borderRadius(10)
          .onChange((value: string) => this.keyword = value)
          .onSubmit(() => { void this.loadCourses(); })
        Button('搜索').height(40).backgroundColor('#176B87').fontColor(Color.White)
          .onClick(() => { void this.loadCourses(); })
      }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
      if (this.loading) {
        Column({ space: 10 }) { LoadingProgress().color('#176B87'); Text('正在加载课程数据').fontSize(13).fontColor('#718096') }
          .layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.errorText.length > 0) {
        Column({ space: 10 }) { Text(this.errorText).fontSize(14).fontColor('#C04A4A'); Button('重新加载').onClick(() => { void this.loadCourses(); }) }
          .layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.courses.length === 0) {
        Column({ space: 8 }) { Text('暂无课程').fontSize(16).fontColor('#516B80'); Text('可调整搜索条件').fontSize(13).fontColor('#8999A4') }
          .layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.courses, (course: CourseSummary) => { ListItem() { this.courseRow(course) } }, (course: CourseSummary) => `${course.id}`)
        }.width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 16 })
      }
    }.width('100%').height('100%').backgroundColor('#EDF5F7')
  }
}
