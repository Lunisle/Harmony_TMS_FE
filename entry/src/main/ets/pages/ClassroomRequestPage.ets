import { UserInfo } from '../models/ApiModels';

interface RequestClassroomPreview {
  id: number;
  campus: string;
  building: string;
  roomNo: string;
  type: string;
  capacity: number;
}

interface ClassroomRequestPreview {
  id: number;
  classroomId: number;
  classroomName: string;
  classroomLocation: string;
  startTime: string;
  endTime: string;
  participantCount: number;
  purpose: string;
  status: string;
}

@Component
export struct ClassroomRequestPage {
  @Prop user: UserInfo;
  @Link page: number;
  @State activeTab: number = 0;
  @State keyword: string = '';
  @State campusFilter: string = '';
  @State typeFilter: string = '';
  @State capacityFilter: number = 0;
  @State selectedClassroom: RequestClassroomPreview | null = null;
  @State selectedRequest: ClassroomRequestPreview | null = null;
  @State formVisible: boolean = false;
  @State detailVisible: boolean = false;
  @State cancelVisible: boolean = false;
  @State startTime: string = '';
  @State endTime: string = '';
  @State participantCount: string = '';
  @State purpose: string = '';
  @State requests: ClassroomRequestPreview[] = [
    {
      id: 1001, classroomId: 1, classroomName: 'A101', classroomLocation: '主校区 · 第一教学楼',
      startTime: '2026-07-18 14:00', endTime: '2026-07-18 16:00', participantCount: 36,
      purpose: '班级学习经验交流会', status: 'PENDING'
    },
    {
      id: 1002, classroomId: 3, classroomName: 'B305', classroomLocation: '主校区 · 第二教学楼',
      startTime: '2026-07-10 09:00', endTime: '2026-07-10 11:00', participantCount: 28,
      purpose: '课程小组汇报排练', status: 'APPROVED'
    },
    {
      id: 1003, classroomId: 5, classroomName: 'D401', classroomLocation: '沙河校区 · 实验楼',
      startTime: '2026-07-06 19:00', endTime: '2026-07-06 21:00', participantCount: 24,
      purpose: '社团技术分享活动', status: 'COMPLETED'
    }
  ];

  private classrooms: RequestClassroomPreview[] = [
    { id: 1, campus: '主校区', building: '第一教学楼', roomNo: 'A101', type: '多媒体教室', capacity: 80 },
    { id: 2, campus: '主校区', building: '第一教学楼', roomNo: 'A203', type: '智慧教室', capacity: 48 },
    { id: 3, campus: '主校区', building: '第二教学楼', roomNo: 'B305', type: '普通教室', capacity: 60 },
    { id: 4, campus: '沙河校区', building: '综合楼', roomNo: 'C210', type: '机房', capacity: 50 },
    { id: 5, campus: '沙河校区', building: '实验楼', roomNo: 'D401', type: '实验室', capacity: 32 }
  ];
  private campuses: string[] = ['主校区', '沙河校区'];
  private classroomTypes: string[] = ['多媒体教室', '智慧教室', '普通教室', '机房', '实验室'];
  private capacityLevels: number[] = [30, 50, 80];

  private visibleClassrooms(): RequestClassroomPreview[] {
    const keyword = this.keyword.trim().toLowerCase();
    return this.classrooms.filter((item: RequestClassroomPreview) => {
      const keywordMatched = keyword.length === 0 || item.roomNo.toLowerCase().includes(keyword) || item.building.toLowerCase().includes(keyword);
      const campusMatched = this.campusFilter.length === 0 || item.campus === this.campusFilter;
      const typeMatched = this.typeFilter.length === 0 || item.type === this.typeFilter;
      const capacityMatched = this.capacityFilter === 0 || item.capacity >= this.capacityFilter;
      return keywordMatched && campusMatched && typeMatched && capacityMatched;
    });
  }

  private cycleText(current: string, values: string[]): string {
    if (values.length === 0) return '';
    if (current.length === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? '' : values[index + 1];
  }

  private cycleNumber(current: number, values: number[]): number {
    if (values.length === 0) return 0;
    if (current === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? 0 : values[index + 1];
  }

  private statusText(status: string): string {
    if (status === 'DRAFT') return '草稿';
    if (status === 'PENDING') return '待审批';
    if (status === 'APPROVED') return '已通过';
    if (status === 'REJECTED') return '已驳回';
    if (status === 'CANCELLED') return '已取消';
    if (status === 'COMPLETED') return '已完成';
    return status;
  }

  private statusColor(status: string): string {
    if (status === 'PENDING') return '#A66B21';
    if (status === 'APPROVED' || status === 'COMPLETED') return '#167C68';
    if (status === 'REJECTED') return '#B04A4A';
    return '#718096';
  }

  private statusBackground(status: string): string {
    if (status === 'PENDING') return '#FBF0DC';
    if (status === 'APPROVED' || status === 'COMPLETED') return '#E2F3EE';
    if (status === 'REJECTED') return '#F7E5E5';
    return '#EEF1F3';
  }

  private openApplication(item: RequestClassroomPreview): void {
    this.selectedClassroom = item;
    this.startTime = '';
    this.endTime = '';
    this.participantCount = '';
    this.purpose = '';
    this.formVisible = true;
  }

  private validTime(value: string): boolean {
    return /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(value);
  }

  private submitApplication(): void {
    if (this.selectedClassroom === null) return;
    const count = Number(this.participantCount);
    if (!this.validTime(this.startTime) || !this.validTime(this.endTime)) {
      this.showToast('请按 YYYY-MM-DD HH:mm 填写使用时间');
      return;
    }
    const start = Date.parse(this.startTime.replace(' ', 'T'));
    const end = Date.parse(this.endTime.replace(' ', 'T'));
    if (!Number.isFinite(start) || !Number.isFinite(end) || start >= end) {
      this.showToast('结束时间必须晚于开始时间');
      return;
    }
    if (!Number.isInteger(count) || count <= 0 || count > this.selectedClassroom.capacity) {
      this.showToast(`使用人数应为 1 至 ${this.selectedClassroom.capacity} 人`);
      return;
    }
    if (!this.purpose.trim()) {
      this.showToast('请填写使用用途和申请说明');
      return;
    }
    const request: ClassroomRequestPreview = {
      id: this.nextRequestId(),
      classroomId: this.selectedClassroom.id,
      classroomName: this.selectedClassroom.roomNo,
      classroomLocation: `${this.selectedClassroom.campus} · ${this.selectedClassroom.building}`,
      startTime: this.startTime,
      endTime: this.endTime,
      participantCount: count,
      purpose: this.purpose.trim(),
      status: 'PENDING'
    };
    this.requests = [request, ...this.requests];
    this.formVisible = false;
    this.activeTab = 1;
    this.showToast('静态预览：申请已提交，等待审批');
  }

  private nextRequestId(): number {
    let maximum = 1000;
    this.requests.forEach((item: ClassroomRequestPreview) => maximum = Math.max(maximum, item.id));
    return maximum + 1;
  }

  private openRequestDetail(item: ClassroomRequestPreview): void {
    this.selectedRequest = item;
    this.detailVisible = true;
  }

  private cancelRequest(): void {
    if (this.selectedRequest === null) return;
    const id = this.selectedRequest.id;
    this.requests = this.requests.map((item: ClassroomRequestPreview) => {
      if (item.id === id) {
        return {
          id: item.id, classroomId: item.classroomId, classroomName: item.classroomName,
          classroomLocation: item.classroomLocation, startTime: item.startTime, endTime: item.endTime,
          participantCount: item.participantCount, purpose: item.purpose, status: 'CANCELLED'
        };
      }
      return item;
    });
    this.cancelVisible = false;
    this.detailVisible = false;
    this.selectedRequest = null;
    this.showToast('静态预览：申请已取消');
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2300 }); } catch (_) {}
  }

  @Builder
  private tabSelector() {
    Row() {
      Text('申请教室').layoutWeight(1).textAlign(TextAlign.Center).fontSize(15)
        .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === 0 ? '#176B87' : '#718096').padding({ top: 12, bottom: 12 })
        .border({ width: { bottom: this.activeTab === 0 ? 3 : 0 }, color: '#176B87' }).onClick(() => this.activeTab = 0)
      Text('我的申请').layoutWeight(1).textAlign(TextAlign.Center).fontSize(15)
        .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === 1 ? '#176B87' : '#718096').padding({ top: 12, bottom: 12 })
        .border({ width: { bottom: this.activeTab === 1 ? 3 : 0 }, color: '#176B87' }).onClick(() => this.activeTab = 1)
    }.width('100%').backgroundColor(Color.White)
  }

  @Builder
  private classroomCard(item: RequestClassroomPreview) {
    Row({ space: 12 }) {
      Column({ space: 5 }) {
        Row() {
          Text(item.roomNo).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text('可申请').fontSize(11).fontColor('#167C68').backgroundColor('#E2F3EE')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9)
        }.width('100%')
        Text(`${item.campus} · ${item.building}`).fontSize(12).fontColor('#718096').width('100%')
        Text(`${item.type} · ${item.capacity} 座`).fontSize(13).fontColor('#31566D').width('100%')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text('申请 ›').fontSize(13).fontColor('#176B87').width(55).textAlign(TextAlign.Center)
    }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
      .shadow({ radius: 8, color: '#0D000000', offsetY: 2 }).onClick(() => this.openApplication(item))
  }

  @Builder
  private requestCard(item: ClassroomRequestPreview) {
    Column({ space: 10 }) {
      Row() {
        Text(item.classroomName).fontSize(17).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
        Text(this.statusText(item.status)).fontSize(11).fontColor(this.statusColor(item.status))
          .backgroundColor(this.statusBackground(item.status)).padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9)
      }
      Text(item.classroomLocation).fontSize(12).fontColor('#718096').width('100%')
      Row() {
        Text(`${item.startTime} — ${item.endTime.substring(11)}`).fontSize(13).fontColor('#31566D').layoutWeight(1)
        Text('查看详情 ›').fontSize(12).fontColor('#176B87')
      }.width('100%')
    }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
      .onClick(() => this.openRequestDetail(item))
  }

  @Builder
  private applyView() {
    Column() {
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索教室编号或楼栋', text: this.keyword }).layoutWeight(1).height(40)
          .backgroundColor(Color.White).borderRadius(10).onChange((value: string) => this.keyword = value)
        Button(this.campusFilter || '校区').height(38).backgroundColor('#E4F2F5').fontColor('#176B87')
          .onClick(() => this.campusFilter = this.cycleText(this.campusFilter, this.campuses))
      }.width('100%').padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Row({ space: 8 }) {
        Button(this.typeFilter || '全部类型').layoutWeight(1).height(36).fontSize(12).backgroundColor('#EAF5F7').fontColor('#31566D')
          .onClick(() => this.typeFilter = this.cycleText(this.typeFilter, this.classroomTypes))
        Button(this.capacityFilter > 0 ? `${this.capacityFilter}人以上` : '不限容量').layoutWeight(1).height(36).fontSize(12)
          .backgroundColor('#EAF5F7').fontColor('#31566D').onClick(() => this.capacityFilter = this.cycleNumber(this.capacityFilter, this.capacityLevels))
      }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
      Text(`找到 ${this.visibleClassrooms().length} 间可申请教室`).fontSize(12).fontColor('#718096').width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })
      if (this.visibleClassrooms().length === 0) {
        Column({ space: 8 }) {
          Text('暂无符合条件的教室').fontSize(16).fontColor('#516B80')
          Text('请调整校区、类型或容量条件').fontSize(13).fontColor('#8999A4')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.visibleClassrooms(), (item: RequestClassroomPreview) => { ListItem() { this.classroomCard(item) } },
            (item: RequestClassroomPreview) => `${item.id}`)
        }.width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 16 })
      }
    }.width('100%').layoutWeight(1)
  }

  @Builder
  private myRequestsView() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('我的教室申请').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text('查看审批进度，待审批申请可在使用前取消').fontSize(12).fontColor('#718096').width('100%')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text(`${this.requests.length}条`).fontSize(12).fontColor('#176B87')
      }.width('100%').padding({ left: 20, right: 20, top: 16, bottom: 12 })
      List() {
        ForEach(this.requests, (item: ClassroomRequestPreview) => { ListItem() { this.requestCard(item) } },
          (item: ClassroomRequestPreview) => `${item.id}`)
      }.width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 16 })
    }.width('100%').layoutWeight(1)
  }

  @Builder
  private applicationDialog() {
    if (this.formVisible && this.selectedClassroom !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text('提交教室申请').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }
            Column({ space: 4 }) {
              Text(`${this.selectedClassroom.campus} · ${this.selectedClassroom.building}`).fontSize(12).fontColor('#718096').width('100%')
              Text(`${this.selectedClassroom.roomNo} · ${this.selectedClassroom.type} · ${this.selectedClassroom.capacity}座`)
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
            }.width('100%').padding(12).backgroundColor('#EAF5F7').borderRadius(10).alignItems(HorizontalAlign.Start)
            TextInput({ placeholder: '开始时间 YYYY-MM-DD HH:mm', text: this.startTime }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.startTime = value)
            TextInput({ placeholder: '结束时间 YYYY-MM-DD HH:mm', text: this.endTime }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.endTime = value)
            TextInput({ placeholder: '使用人数', text: this.participantCount }).type(InputType.Number).height(46)
              .backgroundColor('#F1F6F8').borderRadius(10).onChange((value: string) => this.participantCount = value)
            TextArea({ placeholder: '使用用途和申请说明（最多 255 字）', text: this.purpose }).height(100)
              .backgroundColor('#F1F6F8').borderRadius(10).maxLength(255).onChange((value: string) => this.purpose = value)
            Text('普通申请最多提前一周；实际提交时将由后端校验时段冲突。').fontSize(12).fontColor('#8999A4').width('100%')
            Button('提交申请').width('100%').height(48).backgroundColor('#197C93').fontColor(Color.White)
              .onClick(() => this.submitApplication())
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('90%').height('82%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private requestDetailDialog() {
    if (this.detailVisible && this.selectedRequest !== null && !this.cancelVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Column({ space: 13 }) {
          Row() {
            Text('申请详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text(this.statusText(this.selectedRequest.status)).fontSize(11).fontColor(this.statusColor(this.selectedRequest.status))
              .backgroundColor(this.statusBackground(this.selectedRequest.status)).padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9)
            Text('×').fontSize(26).fontColor('#718096').margin({ left: 8 }).onClick(() => this.detailVisible = false)
          }
          Row() { Text('教室').width(76).fontColor('#718096'); Text(this.selectedRequest.classroomName).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('位置').width(76).fontColor('#718096'); Text(this.selectedRequest.classroomLocation).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('开始时间').width(76).fontColor('#718096'); Text(this.selectedRequest.startTime).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('结束时间').width(76).fontColor('#718096'); Text(this.selectedRequest.endTime).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('使用人数').width(76).fontColor('#718096'); Text(`${this.selectedRequest.participantCount} 人`).fontColor('#17324D').layoutWeight(1) }
          Column({ space: 5 }) {
            Text('使用用途').fontSize(13).fontColor('#718096').width('100%')
            Text(this.selectedRequest.purpose).fontSize(14).fontColor('#17324D').width('100%')
          }.width('100%').alignItems(HorizontalAlign.Start)
          if (this.selectedRequest.status === 'PENDING' || this.selectedRequest.status === 'DRAFT') {
            Button('取消申请').width('100%').backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.cancelVisible = true)
          }
        }.width('88%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private cancelDialog() {
    if (this.cancelVisible && this.selectedRequest !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Column({ space: 14 }) {
          Text('确认取消申请？').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`将取消 ${this.selectedRequest.classroomName} 在 ${this.selectedRequest.startTime} 的使用申请。`)
            .fontSize(14).fontColor('#516B80').width('100%')
          Row({ space: 10 }) {
            Button('返回').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.cancelVisible = false)
            Button('确认取消').layoutWeight(1).backgroundColor('#B04A4A').fontColor(Color.White).onClick(() => this.cancelRequest())
          }
        }.width('84%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0)
          Column({ space: 3 }) {
            Text('教室申请').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
            Text(this.user.name ?? this.user.username).fontSize(12).fontColor('#718096').width('100%')
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Text('静态预览').fontSize(11).fontColor('#176B87').backgroundColor('#DCEFF2')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(8)
        }.width('100%').padding({ left: 18, right: 20, top: 16, bottom: 10 })
        this.tabSelector()
        if (this.activeTab === 0) {
          this.applyView()
        } else {
          this.myRequestsView()
        }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.applicationDialog()
      this.requestDetailDialog()
      this.cancelDialog()
    }.width('100%').height('100%')
  }
}
