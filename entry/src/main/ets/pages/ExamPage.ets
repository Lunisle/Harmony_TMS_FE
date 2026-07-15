import { ApiClient } from '../services/ApiClient';
import { ClassroomListItem, CourseSummary, ExamListItem, ExamMutationRequest, SemesterOption, StudentOptionClassGroup, TeacherListItem } from '../models/ApiModels';

@Component
export struct ExamPage {
  @Link page: number;
  @State exams: ExamListItem[] = [];
  @State total: number = 0;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State pageSize: number = 10;
  @State keyword: string = '';
  @State formVisible: boolean = false;
  @State detailVisible: boolean = false;
  @State selected: ExamListItem | null = null;
  @State editingId: number = 0;
  @State semesterId: string = '';
  @State courseId: string = '';
  @State classGroupId: string = '';
  @State classroomId: string = '';
  @State invigilatorId: string = '';
  @State startYear: string = '';
  @State startMonth: string = '';
  @State startDay: string = '';
  @State startHour: string = '';
  @State startMinute: string = '';
  @State endYear: string = '';
  @State endMonth: string = '';
  @State endDay: string = '';
  @State endHour: string = '';
  @State endMinute: string = '';
  @State loading: boolean = false;
  @State courses: CourseSummary[] = [];
  @State teachers: TeacherListItem[] = [];
  @State classGroups: StudentOptionClassGroup[] = [];
  @State classrooms: ClassroomListItem[] = [];
  @State semesters: SemesterOption[] = [];

  aboutToAppear(): void { void this.initialize(); }

  private async initialize(): Promise<void> {
    await this.loadOptions();
    await this.load();
  }

  private async loadOptions(): Promise<void> {
    try {
      this.courses = await ApiClient.getCourses();
      this.teachers = (await ApiClient.getTeachers(1, 100)).items;
      this.classGroups = await ApiClient.getClassGroups();
      this.classrooms = (await ApiClient.getClassrooms(1, 100)).items;
      this.semesters = await ApiClient.getSemesterOptions();
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '加载考试选项失败');
    }
  }

  private async load(): Promise<void> {
    this.loading = true;
    try {
      const result = await ApiClient.getExams(this.currentPage, this.pageSize, this.keyword.trim());
      this.exams = result.items;
      this.total = result.total;
      this.totalPages = Math.max(1, result.totalPages);
      if (this.currentPage > this.totalPages) this.currentPage = this.totalPages;
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '加载考试安排失败');
    } finally {
      this.loading = false;
    }
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {}
  }

  private formatTime(value: string): string {
    const matched = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/);
    if (matched === null) return value;
    return `${matched[1]}年${matched[2]}月${matched[3]}日${matched[4]}时${matched[5]}分`;
  }

  private setStartParts(value: string): void {
    const matched = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/);
    this.startYear = matched?.[1] ?? '';
    this.startMonth = matched?.[2] ?? '';
    this.startDay = matched?.[3] ?? '';
    this.startHour = matched?.[4] ?? '';
    this.startMinute = matched?.[5] ?? '';
  }

  private setEndParts(value: string): void {
    const matched = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/);
    this.endYear = matched?.[1] ?? '';
    this.endMonth = matched?.[2] ?? '';
    this.endDay = matched?.[3] ?? '';
    this.endHour = matched?.[4] ?? '';
    this.endMinute = matched?.[5] ?? '';
  }

  private buildUtcTime(yearText: string, monthText: string, dayText: string, hourText: string, minuteText: string): string | null {
    const year = Number(yearText);
    const month = Number(monthText);
    const day = Number(dayText);
    const hour = Number(hourText);
    const minute = Number(minuteText);
    if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day) || !Number.isInteger(hour) || !Number.isInteger(minute)) return null;
    const milliseconds = Date.UTC(year, month - 1, day, hour, minute, 0, 0);
    const date = new Date(milliseconds);
    if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day || date.getUTCHours() !== hour || date.getUTCMinutes() !== minute) return null;
    return date.toISOString();
  }

  private idIndex(value: string, values: number[]): number {
    const index = values.indexOf(Number(value));
    return index >= 0 ? index + 1 : 0;
  }

  private selectOptions(placeholder: string, labels: string[]): SelectOption[] {
    const result: SelectOption[] = [{ value: placeholder }];
    labels.forEach((label: string) => {
      const option: SelectOption = { value: label };
      result.push(option);
    });
    return result;
  }

  private semesterLabels(): string[] { return this.semesters.map((item: SemesterOption) => item.label); }
  private courseLabels(): string[] { return this.courses.map((item: CourseSummary) => `${item.code} · ${item.name}`); }
  private classGroupLabels(): string[] { return this.classGroups.map((item: StudentOptionClassGroup) => `${item.code ?? ''} · ${item.name}`); }
  private classroomLabels(): string[] { return this.classrooms.map((item: ClassroomListItem) => `${item.roomNo} · ${item.building ?? ''}`); }
  private teacherLabels(): string[] { return this.teachers.map((item: TeacherListItem) => `${item.employeeNo} · ${item.name}`); }

  private openCreate(): void {
    this.editingId = 0;
    this.semesterId = ''; this.courseId = ''; this.classGroupId = ''; this.classroomId = ''; this.invigilatorId = '';
    this.setStartParts(''); this.setEndParts('');
    this.formVisible = true;
  }

  private async openDetail(item: ExamListItem): Promise<void> {
    try { this.selected = await ApiClient.getExam(item.id); } catch (_) { this.selected = item; }
    this.detailVisible = true;
  }

  private openEdit(): void {
    if (this.selected === null) return;
    const item = this.selected;
    this.editingId = item.id;
    this.semesterId = `${item.semesterId}`;
    this.courseId = `${item.courseId}`;
    this.classGroupId = `${item.classGroupId}`;
    this.classroomId = `${item.classroomId}`;
    this.invigilatorId = item.invigilatorId ? `${item.invigilatorId}` : '';
    this.setStartParts(item.startTime);
    this.setEndParts(item.endTime);
    this.detailVisible = false;
    this.formVisible = true;
  }

  private async save(): Promise<void> {
    const startTime = this.buildUtcTime(this.startYear, this.startMonth, this.startDay, this.startHour, this.startMinute);
    const endTime = this.buildUtcTime(this.endYear, this.endMonth, this.endDay, this.endHour, this.endMinute);
    if (startTime === null || endTime === null || Date.parse(startTime) >= Date.parse(endTime)) {
      this.showToast('请填写有效的开始和结束年月日时分');
      return;
    }
    const data: ExamMutationRequest = {
      semesterId: Number(this.semesterId), courseId: Number(this.courseId), classGroupId: Number(this.classGroupId),
      classroomId: Number(this.classroomId), startTime: startTime, endTime: endTime,
      invigilatorId: this.invigilatorId.length > 0 ? Number(this.invigilatorId) : null
    };
    if (!Number.isInteger(data.semesterId) || !Number.isInteger(data.courseId) || !Number.isInteger(data.classGroupId) || !Number.isInteger(data.classroomId)) {
      this.showToast('请选择学期、课程、班级和教室');
      return;
    }
    try {
      const editing = this.editingId > 0;
      if (editing) await ApiClient.updateExam(this.editingId, data); else await ApiClient.createExam(data);
      this.formVisible = false;
      await this.load();
      this.showToast(editing ? '考试安排已更新' : '考试安排已创建');
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '保存考试安排失败');
    }
  }

  private async remove(item: ExamListItem): Promise<void> {
    try { await ApiClient.deleteExam(item.id); await this.load(); this.showToast('考试安排已删除'); }
    catch (error) { this.showToast(error instanceof Error ? error.message : '删除考试安排失败'); }
  }

  @Builder
  private requiredLabel(label: string) {
    Row({ space: 3 }) {
      Text('*').fontSize(15).fontColor('#D94B4B').fontWeight(FontWeight.Bold)
      Text(label).fontSize(13).fontColor('#516B80')
    }.width('100%').justifyContent(FlexAlign.Start)
  }

  @Builder
  private optionalLabel(label: string) {
    Text(label).fontSize(13).fontColor('#718096').width('100%').textAlign(TextAlign.Start)
  }

  @Builder
  private examRow(item: ExamListItem) {
    Column({ space: 7 }) {
      Row() {
        Column({ space: 3 }) {
          Text(item.courseName ?? `课程 ${item.courseId}`).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#17324D').width('100%')
          Text(`${item.classGroupName ?? `班级 ${item.classGroupId}`} · ${item.classroomRoomNo ?? `教室 ${item.classroomId}`}`).fontSize(12).fontColor('#718096').width('100%')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text(`学期 ${item.semesterId}`).fontSize(12).fontColor('#176B87')
      }
      Text(`开始：${this.formatTime(item.startTime)}`).fontSize(13).fontColor('#516B80').width('100%')
      Text(`结束：${this.formatTime(item.endTime)}`).fontSize(13).fontColor('#516B80').width('100%')
      Text(`监考：${item.invigilatorName ?? '未安排'}`).fontSize(12).fontColor('#8999A4').width('100%')
      Row({ space: 8 }) {
        Button('详情').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { void this.openDetail(item); })
        Button('删除').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => { void this.remove(item); })
      }.width('100%')
    }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
  }

  @Builder
  private detailDialog() {
    if (this.detailVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Column({ space: 12 }) {
          Row() {
            Text('考试详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text('×').fontSize(26).fontColor('#718096').onClick(() => this.detailVisible = false)
          }
          Row() { Text('课程').width(72).fontColor('#718096'); Text(this.selected.courseName ?? `课程 ${this.selected.courseId}`).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('班级').width(72).fontColor('#718096'); Text(this.selected.classGroupName ?? `班级 ${this.selected.classGroupId}`).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('教室').width(72).fontColor('#718096'); Text(this.selected.classroomRoomNo ?? `教室 ${this.selected.classroomId}`).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('开始时间').width(72).fontColor('#718096'); Text(this.formatTime(this.selected.startTime)).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('结束时间').width(72).fontColor('#718096'); Text(this.formatTime(this.selected.endTime)).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('监考教师').width(72).fontColor('#718096'); Text(this.selected.invigilatorName ?? '未安排').fontColor('#17324D').layoutWeight(1) }
          Button('编辑').width('100%').backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.openEdit())
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private formDialog() {
    if (this.formVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.formVisible = false)
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text(this.editingId > 0 ? '编辑考试安排' : '新建考试安排').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }
            this.requiredLabel('学期')
            Select(this.selectOptions('选择学期', this.semesterLabels())).selected(this.idIndex(this.semesterId, this.semesters.map((item: SemesterOption) => item.id))).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.semesterId = index > 0 ? `${this.semesters[index - 1].id}` : '')
            this.requiredLabel('课程')
            Select(this.selectOptions('选择课程', this.courseLabels())).selected(this.idIndex(this.courseId, this.courses.map((item: CourseSummary) => item.id))).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.courseId = index > 0 ? `${this.courses[index - 1].id}` : '')
            this.requiredLabel('班级')
            Select(this.selectOptions('选择班级', this.classGroupLabels())).selected(this.idIndex(this.classGroupId, this.classGroups.map((item: StudentOptionClassGroup) => item.id))).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.classGroupId = index > 0 ? `${this.classGroups[index - 1].id}` : '')
            this.requiredLabel('教室')
            Select(this.selectOptions('选择教室', this.classroomLabels())).selected(this.idIndex(this.classroomId, this.classrooms.map((item: ClassroomListItem) => item.id))).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.classroomId = index > 0 ? `${this.classrooms[index - 1].id}` : '')
            this.requiredLabel('开始时间')
            Row({ space: 5 }) {
              TextInput({ placeholder: '年', text: this.startYear }).type(InputType.Number).maxLength(4).layoutWeight(2).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.startYear = value)
              TextInput({ placeholder: '月', text: this.startMonth }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.startMonth = value)
              TextInput({ placeholder: '日', text: this.startDay }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.startDay = value)
              TextInput({ placeholder: '时', text: this.startHour }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.startHour = value)
              TextInput({ placeholder: '分', text: this.startMinute }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.startMinute = value)
            }.width('100%')
            this.requiredLabel('结束时间')
            Row({ space: 5 }) {
              TextInput({ placeholder: '年', text: this.endYear }).type(InputType.Number).maxLength(4).layoutWeight(2).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.endYear = value)
              TextInput({ placeholder: '月', text: this.endMonth }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.endMonth = value)
              TextInput({ placeholder: '日', text: this.endDay }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.endDay = value)
              TextInput({ placeholder: '时', text: this.endHour }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.endHour = value)
              TextInput({ placeholder: '分', text: this.endMinute }).type(InputType.Number).maxLength(2).layoutWeight(1).height(38).fontSize(12).backgroundColor('#F1F6F8').borderRadius(8).onChange((value: string) => this.endMinute = value)
            }.width('100%')
            this.optionalLabel('监考教师（可选）')
            Select(this.selectOptions('选择监考教师（可选）', this.teacherLabels())).selected(this.idIndex(this.invigilatorId, this.teachers.map((item: TeacherListItem) => item.id))).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.invigilatorId = index > 0 ? `${this.teachers[index - 1].id}` : '')
            Button('保存').width('100%').height(48).backgroundColor('#197C93').fontColor(Color.White).onClick(() => { void this.save(); })
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('88%').height('86%')
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0)
          Text('考试安排').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text(`${this.total} 条`).fontSize(13).fontColor('#718096')
        }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索课程或班级', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10)
            .onChange((value: string) => this.keyword = value).onSubmit(() => { this.currentPage = 1; void this.load(); })
          Button('搜索').height(40).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { this.currentPage = 1; void this.load(); })
          Button('新建').height(40).backgroundColor('#176B87').fontColor(Color.White).onClick(() => this.openCreate())
        }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
        if (this.loading) {
          LoadingProgress().color('#176B87').layoutWeight(1)
        } else {
          List() {
            ForEach(this.exams, (item: ExamListItem) => { ListItem() { this.examRow(item) } }, (item: ExamListItem) => `${item.id}`)
          }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 })
          Row({ space: 12 }) {
            Button('上一页').enabled(this.currentPage > 1 && !this.loading).backgroundColor('#E4F2F5').fontColor('#176B87')
              .onClick(() => { this.currentPage--; void this.load(); })
            Text(`${this.currentPage} / ${this.totalPages}`).fontSize(13).fontColor('#516B80')
            Button('下一页').enabled(this.currentPage < this.totalPages && !this.loading).backgroundColor('#E4F2F5').fontColor('#176B87')
              .onClick(() => { this.currentPage++; void this.load(); })
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 16 })
        }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.formDialog()
      this.detailDialog()
    }.width('100%').height('100%')
  }
}
