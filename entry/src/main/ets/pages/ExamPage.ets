import { ApiClient } from '../services/ApiClient';
import { ExamListItem, ExamMutationRequest, CourseSummary, TeacherListItem, StudentOptionClassGroup, ClassroomListItem, SemesterOption } from '../models/ApiModels';

@Component
export struct ExamPage {
  @Link page: number;
  @State exams: ExamListItem[] = [];
  @State keyword: string = '';
  @State formVisible: boolean = false;
  @State detailVisible: boolean = false;
  @State selected: ExamListItem | null = null;
  @State editingId: number = 0;
  @State semesterId: string = '';
  @State courseId: string = '';
  @State classGroupId: string = '';
  @State classroomId: string = '';
  @State startTime: string = '';
  @State endTime: string = '';
  @State invigilatorId: string = '';
  @State loading: boolean = false;
  @State courses: CourseSummary[] = [];
  @State teachers: TeacherListItem[] = [];
  @State classGroups: StudentOptionClassGroup[] = [];
  @State classrooms: ClassroomListItem[] = [];
  @State semesters: SemesterOption[] = [];

  aboutToAppear(): void { void this.initialize(); }
  private async initialize(): Promise<void> { await this.loadOptions(); await this.load(); }
  private async loadOptions(): Promise<void> {
    try {
      this.courses = await ApiClient.getCourses();
      this.teachers = (await ApiClient.getTeachers(1, 100)).items;
      this.classGroups = await ApiClient.getClassGroups();
      this.classrooms = (await ApiClient.getClassrooms(1, 100)).items;
      this.semesters = await ApiClient.getSemesterOptions();
    } catch (error) { this.showToast(error instanceof Error ? error.message : '加载考试选项失败'); }
  }
  private cycleId(current: string, values: number[]): string { if (values.length === 0) return ''; const id = Number(current); const index = values.indexOf(id); return `${index < 0 || index >= values.length - 1 ? values[0] : values[index + 1]}`; }
  private courseLabel(): string { const item = this.courses.find((v: CourseSummary) => v.id === Number(this.courseId)); return item ? `${item.code} ${item.name}` : '选择课程'; }
  private classGroupLabel(): string { const item = this.classGroups.find((v: StudentOptionClassGroup) => v.id === Number(this.classGroupId)); return item ? item.name : '选择班级组'; }
  private classroomLabel(): string { const item = this.classrooms.find((v: ClassroomListItem) => v.id === Number(this.classroomId)); return item ? `${item.roomNo} ${item.building ?? ''}` : '选择教室'; }
  private teacherLabel(): string { const item = this.teachers.find((v: TeacherListItem) => v.id === Number(this.invigilatorId)); return item ? item.name : '选择监考教师（可选）'; }
  private semesterLabel(): string { const item = this.semesters.find((v: SemesterOption) => v.id === Number(this.semesterId)); return item ? item.label : '选择学期'; }
  private async load(): Promise<void> { this.loading = true; try { this.exams = (await ApiClient.getExams(1, 100, this.keyword)).items; } catch (error) { this.showToast(error instanceof Error ? error.message : '加载考试安排失败'); } finally { this.loading = false; } }
  private async openDetail(item: ExamListItem): Promise<void> {
    try { this.selected = await ApiClient.getExam(item.id); } catch (_) { this.selected = item; }
    this.detailVisible = true;
  }
  private showToast(message: string): void { try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {} }
  private openCreate(): void { this.editingId = 0; this.semesterId = ''; this.courseId = ''; this.classGroupId = ''; this.classroomId = ''; this.startTime = ''; this.endTime = ''; this.invigilatorId = ''; this.formVisible = true; }
  private openEdit(item: ExamListItem): void {
    this.editingId = item.id;
    this.semesterId = `${item.semesterId}`;
    this.courseId = `${item.courseId}`;
    this.classGroupId = `${item.classGroupId}`;
    this.classroomId = `${item.classroomId}`;
    this.startTime = item.startTime.substring(0, 16).replace('T', ' ');
    this.endTime = item.endTime.substring(0, 16).replace('T', ' ');
    this.invigilatorId = item.invigilatorId ? `${item.invigilatorId}` : '';
    this.detailVisible = false;
    this.formVisible = true;
  }
  private async save(): Promise<void> {
    const data: ExamMutationRequest = { semesterId: Number(this.semesterId), courseId: Number(this.courseId), classGroupId: Number(this.classGroupId), classroomId: Number(this.classroomId), startTime: new Date(this.startTime.replace(' ', 'T')).toISOString(), endTime: new Date(this.endTime.replace(' ', 'T')).toISOString(), invigilatorId: this.invigilatorId.length > 0 ? Number(this.invigilatorId) : null };
    if (!Number.isInteger(data.semesterId) || !Number.isInteger(data.courseId) || !Number.isInteger(data.classGroupId) || !Number.isInteger(data.classroomId) || !Number.isFinite(Date.parse(data.startTime)) || !Number.isFinite(Date.parse(data.endTime)) || Date.parse(data.startTime) >= Date.parse(data.endTime)) { this.showToast('请完整填写考试关联 ID 和正确的时间'); return; }
    try {
      const editing = this.editingId > 0;
      if (editing) { await ApiClient.updateExam(this.editingId, data); } else { await ApiClient.createExam(data); }
      this.formVisible = false; this.editingId = 0; await this.load(); this.showToast(editing ? '考试安排已更新' : '考试安排已创建');
    } catch (error) { this.showToast(error instanceof Error ? error.message : '保存考试安排失败'); }
  }
  private async remove(item: ExamListItem): Promise<void> { try { await ApiClient.deleteExam(item.id); await this.load(); this.showToast('考试安排已删除'); } catch (error) { this.showToast(error instanceof Error ? error.message : '删除考试安排失败'); } }
  @Builder private examRow(item: ExamListItem) { Column({ space: 7 }) { Row() { Column({ space: 3 }) { Text(item.courseName ?? `课程 ${item.courseId}`).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#17324D'); Text(`${item.classGroupName ?? `班级 ${item.classGroupId}`} · ${item.classroomRoomNo ?? `教室 ${item.classroomId}`}`).fontSize(12).fontColor('#718096') }.layoutWeight(1).alignItems(HorizontalAlign.Start); Text(`学期 ${item.semesterId}`).fontSize(12).fontColor('#176B87') }; Text(`${item.startTime} 至 ${item.endTime}`).fontSize(13).fontColor('#516B80').width('100%'); Text(`监考：${item.invigilatorName ?? '未安排'}`).fontSize(12).fontColor('#8999A4').width('100%'); Row({ space: 8 }) { Button('详情').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { void this.openDetail(item); }); Button('删除').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => { void this.remove(item); }) }.width('100%') }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 }) }

  @Builder private detailDialog() {
    if (this.detailVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Column({ space: 12 }) {
          Row() { Text('考试安排详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text('×').fontSize(26).fontColor('#718096').onClick(() => this.detailVisible = false) }.width('100%')
          Text(`课程：${this.selected.courseName ?? this.selected.courseId}`).fontSize(15).fontColor('#17324D').width('100%')
          Text(`班级：${this.selected.classGroupName ?? this.selected.classGroupId}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`教室：${this.selected.classroomRoomNo ?? this.selected.classroomId}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`学期：${this.selected.semesterId}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`时间：${this.selected.startTime} 至 ${this.selected.endTime}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`监考：${this.selected.invigilatorName ?? '未安排'}`).fontSize(14).fontColor('#516B80').width('100%')
          Row({ space: 10 }) {
            Button('编辑').layoutWeight(1).backgroundColor('#176B87').fontColor(Color.White).onClick(() => this.openEdit(this.selected as ExamListItem))
            Button('关闭').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.detailVisible = false)
          }.width('100%')
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }
  @Builder private formDialog() {
    if (this.formVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.formVisible = false)
        Scroll() {
          Column({ space: 10 }) {
            Text(this.editingId > 0 ? '编辑考试安排' : '新建考试安排').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
            Button(this.semesterLabel()).width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.semesterId = this.cycleId(this.semesterId, this.semesters.map((v: SemesterOption) => v.id)))
            Button(this.courseLabel()).width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.courseId = this.cycleId(this.courseId, this.courses.map((v: CourseSummary) => v.id)))
            Button(this.classGroupLabel()).width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.classGroupId = this.cycleId(this.classGroupId, this.classGroups.map((v: StudentOptionClassGroup) => v.id)))
            Button(this.classroomLabel()).width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.classroomId = this.cycleId(this.classroomId, this.classrooms.map((v: ClassroomListItem) => v.id)))
            TextInput({ placeholder: '开始时间：YYYY-MM-DD HH:mm', text: this.startTime }).onChange((v: string) => this.startTime = v)
            TextInput({ placeholder: '结束时间：YYYY-MM-DD HH:mm', text: this.endTime }).onChange((v: string) => this.endTime = v)
            Button(this.teacherLabel()).width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.invigilatorId = this.cycleId(this.invigilatorId, this.teachers.map((v: TeacherListItem) => v.id)))
            Row({ space: 10 }) { Button('取消').layoutWeight(1).onClick(() => this.formVisible = false); Button('保存').layoutWeight(1).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.save(); }) }
          }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.height('78%')
      }.width('100%').height('100%')
    }
  }
  build() { Stack() { Column() { Row() { Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0); Text('考试安排').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text(`${this.exams.length} 条`).fontSize(13).fontColor('#718096') }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 }); Row({ space: 8 }) { TextInput({ placeholder: '搜索课程或班级', text: this.keyword }).layoutWeight(1).onChange((v: string) => this.keyword = v).onSubmit(() => { void this.load(); }); Button('搜索').backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.load(); }); Button('新建').backgroundColor('#176B87').fontColor(Color.White).onClick(() => this.openCreate()) }.width('100%').padding({ left: 20, right: 20, bottom: 10 }); if (this.loading) { LoadingProgress().color('#176B87').layoutWeight(1) } else { List() { ForEach(this.exams, (item: ExamListItem) => { ListItem() { this.examRow(item) } }, (item: ExamListItem) => `${item.id}`) }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 }) } }.width('100%').height('100%').backgroundColor('#EDF5F7'); this.formDialog(); this.detailDialog() }.width('100%').height('100%') }
}
