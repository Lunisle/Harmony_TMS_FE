import { ApiClient } from '../services/ApiClient';
import { ClassroomListItem, ClassroomOptions, ClassroomMutationRequest } from '../models/ApiModels';

interface ClassroomPreview {
  id: number;
  campus: string;
  building: string;
  roomNo: string;
  type: string;
  capacity: number;
  area: number;
  status: string;
}

@Component
export struct AdminClassroomPage {
  @Link page: number;
  @State classrooms: ClassroomPreview[] = [];
  @State total: number = 0;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State loading: boolean = false;
  @State keyword: string = '';
  @State campusFilter: string = '';
  @State buildingFilter: string = '';
  @State typeFilter: string = '';
  @State statusFilter: string = '';
  @State filterVisible: boolean = false;
  @State selected: ClassroomPreview | null = null;
  @State formVisible: boolean = false;
  @State deleteVisible: boolean = false;
  @State editingId: number = 0;
  @State formCampus: string = '';
  @State formBuilding: string = '';
  @State formRoomNo: string = '';
  @State formType: string = '';
  @State formCapacity: string = '';
  @State formArea: string = '';
  @State formStatus: string = 'AVAILABLE';

  private campuses: string[] = [];
  private buildings: string[] = [];
  private classroomTypes: string[] = [];
  private statuses: string[] = ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE'];

  aboutToAppear(): void {
    this.loadOptions();
    this.loadClassrooms();
  }

  private async loadOptions(): Promise<void> {
    try {
      const options: ClassroomOptions = await ApiClient.getClassroomOptions();
      this.campuses = options.campuses ?? [];
      this.buildings = options.buildings ?? [];
      this.classroomTypes = options.types ?? [];
      this.statuses = options.statuses ?? this.statuses;
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '加载教室选项失败');
    }
  }

  private async loadClassrooms(): Promise<void> {
    this.loading = true;
    try {
      const result = await ApiClient.getClassrooms(this.currentPage, this.pageSize, this.keyword, this.campusFilter, this.buildingFilter, this.typeFilter, this.statusFilter);
      this.classrooms = result.items.map((item: ClassroomListItem): ClassroomPreview => ({
        id: item.id, campus: item.campus ?? '', building: item.building ?? '', roomNo: item.roomNo,
        type: item.type ?? '', capacity: item.capacity, area: item.area ?? 0, status: item.status
      }));
      this.total = result.total;
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '加载教室失败');
    } finally {
      this.loading = false;
    }
  }

  private visibleClassrooms(): ClassroomPreview[] {
    const keyword = this.keyword.trim().toLowerCase();
    return this.classrooms.filter((item: ClassroomPreview) => {
      const keywordMatched = keyword.length === 0 || item.roomNo.toLowerCase().includes(keyword) ||
        item.building.toLowerCase().includes(keyword);
      const campusMatched = this.campusFilter.length === 0 || item.campus === this.campusFilter;
      const typeMatched = this.typeFilter.length === 0 || item.type === this.typeFilter;
      const statusMatched = this.statusFilter.length === 0 || item.status === this.statusFilter;
      return keywordMatched && campusMatched && typeMatched && statusMatched;
    });
  }

  private cycleText(current: string, values: string[]): string {
    if (values.length === 0) return '';
    if (current.length === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? '' : values[index + 1];
  }

  private cycleRequiredText(current: string, values: string[]): string {
    if (values.length === 0) return current;
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? values[0] : values[index + 1];
  }

  private statusText(status: string): string {
    if (status === 'AVAILABLE') return '可用';
    if (status === 'OCCUPIED') return '使用中';
    if (status === 'MAINTENANCE') return '维护中';
    return status;
  }

  private statusColor(status: string): string {
    if (status === 'AVAILABLE') return '#167C68';
    if (status === 'OCCUPIED') return '#A66B21';
    return '#B04A4A';
  }

  private statusBackground(status: string): string {
    if (status === 'AVAILABLE') return '#E2F3EE';
    if (status === 'OCCUPIED') return '#FBF0DC';
    return '#F7E5E5';
  }

  private clearFilters(): void {
    this.campusFilter = '';
    this.buildingFilter = '';
    this.typeFilter = '';
    this.statusFilter = '';
  }

  private openCreate(): void {
    this.editingId = 0;
    this.formCampus = '主校区';
    this.formBuilding = '';
    this.formRoomNo = '';
    this.formType = '多媒体教室';
    this.formCapacity = '';
    this.formArea = '';
    this.formStatus = 'AVAILABLE';
    this.formVisible = true;
  }

  private openEdit(): void {
    if (this.selected === null) return;
    this.editingId = this.selected.id;
    this.formCampus = this.selected.campus;
    this.formBuilding = this.selected.building;
    this.formRoomNo = this.selected.roomNo;
    this.formType = this.selected.type;
    this.formCapacity = `${this.selected.capacity}`;
    this.formArea = `${this.selected.area}`;
    this.formStatus = this.selected.status;
    this.selected = null;
    this.formVisible = true;
  }

  private async saveClassroom(): Promise<void> {
    const capacity = Number(this.formCapacity);
    const area = Number(this.formArea);
    if (!this.formCampus.trim() || !this.formBuilding.trim() || !this.formRoomNo.trim()) {
      this.showToast('请填写校区、楼栋和教室编号');
      return;
    }
    if (!Number.isInteger(capacity) || capacity <= 0) {
      this.showToast('教室容量必须为正整数');
      return;
    }
    if (this.formArea.trim().length > 0 && (!Number.isFinite(area) || area < 0)) {
      this.showToast('教室面积不能小于 0');
      return;
    }
    const data: ClassroomMutationRequest = {
      campus: this.formCampus.trim(),
      building: this.formBuilding.trim(),
      roomNo: this.formRoomNo.trim(),
      type: this.formType.trim(),
      capacity: capacity,
      status: this.formStatus
    };
    if (this.formArea.trim().length > 0) data.area = area;
    try {
      if (this.editingId > 0) {
        await ApiClient.updateClassroom(this.editingId, data);
        this.showToast('教室信息已更新');
      } else {
        await ApiClient.createClassroom(data);
        this.showToast('教室已新增');
      }
      this.formVisible = false;
      await this.loadClassrooms();
      await this.loadOptions();
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '保存教室失败');
    }
  }

  private nextId(): number {
    let maximum = 0;
    this.classrooms.forEach((item: ClassroomPreview) => maximum = Math.max(maximum, item.id));
    return maximum + 1;
  }

  private async deleteClassroom(): Promise<void> {
    if (this.selected === null) return;
    const id = this.selected.id;
    try {
      await ApiClient.deleteClassroom(id);
      this.deleteVisible = false;
      this.selected = null;
      this.showToast('教室已删除');
      await this.loadClassrooms();
      await this.loadOptions();
    } catch (error) {
      this.showToast(error instanceof Error ? error.message : '删除教室失败');
    }
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {}
  }

  @Builder
  private classroomCard(item: ClassroomPreview) {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(item.roomNo).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`${item.campus} · ${item.building}`).fontSize(12).fontColor('#718096').width('100%')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text(this.statusText(item.status)).fontSize(12).fontColor(this.statusColor(item.status))
          .backgroundColor(this.statusBackground(item.status)).padding({ left: 9, right: 9, top: 5, bottom: 5 }).borderRadius(10)
      }
      Row({ space: 8 }) {
        Text(item.type).fontSize(13).fontColor('#31566D').layoutWeight(1)
        Text(`${item.capacity}座`).fontSize(13).fontColor('#516B80')
        Text(`${item.area}㎡`).fontSize(13).fontColor('#516B80').width(68).textAlign(TextAlign.End)
      }
    }
    .width('100%').padding(16).backgroundColor(Color.White).borderRadius(16)
    .shadow({ radius: 8, color: '#0D000000', offsetY: 2 }).margin({ bottom: 10 })
    .onClick(() => this.selected = item)
  }

  @Builder
  private detailDialog() {
    if (this.selected !== null && !this.deleteVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#661D3445').onClick(() => this.selected = null)
        Column({ space: 13 }) {
          Row() {
            Text('教室详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text(this.statusText(this.selected.status)).fontSize(12).fontColor(this.statusColor(this.selected.status))
              .backgroundColor(this.statusBackground(this.selected.status)).padding({ left: 9, right: 9, top: 5, bottom: 5 }).borderRadius(10)
            Text('×').fontSize(26).fontColor('#718096').margin({ left: 10 }).onClick(() => this.selected = null)
          }
          Row() { Text('教室编号').width(82).fontColor('#718096'); Text(this.selected.roomNo).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('校区').width(82).fontColor('#718096'); Text(this.selected.campus).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('楼栋').width(82).fontColor('#718096'); Text(this.selected.building).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('类型').width(82).fontColor('#718096'); Text(this.selected.type).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('容量').width(82).fontColor('#718096'); Text(`${this.selected.capacity} 人`).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('面积').width(82).fontColor('#718096'); Text(`${this.selected.area} ㎡`).fontColor('#17324D').layoutWeight(1) }
          Row({ space: 10 }) {
            Button('编辑资料').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.openEdit())
            Button('删除教室').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.deleteVisible = true)
          }
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private filterDialog() {
    if (this.filterVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.filterVisible = false)
        Column({ space: 14 }) {
          Row() {
            Text('筛选教室').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text('×').fontSize(26).fontColor('#718096').onClick(() => this.filterVisible = false)
          }
          Text('点击选项可依次切换').fontSize(13).fontColor('#718096').width('100%')
          Button(this.campusFilter || '全部校区').width('100%').backgroundColor('#EAF5F7').fontColor('#31566D')
            .onClick(() => this.campusFilter = this.cycleText(this.campusFilter, this.campuses))
          Button(this.typeFilter || '全部教室类型').width('100%').backgroundColor('#EAF5F7').fontColor('#31566D')
            .onClick(() => this.typeFilter = this.cycleText(this.typeFilter, this.classroomTypes))
          Button(this.statusFilter.length > 0 ? this.statusText(this.statusFilter) : '全部状态').width('100%')
            .backgroundColor('#EAF5F7').fontColor('#31566D').onClick(() => this.statusFilter = this.cycleText(this.statusFilter, this.statuses))
          Row({ space: 10 }) {
            Button('清空').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.clearFilters())
            Button('应用筛选').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => {
              this.currentPage = 1;
              this.filterVisible = false;
              this.loadClassrooms();
            })
          }
        }.width('88%').padding(20).backgroundColor('#F7FCFD').borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private formDialog() {
    if (this.formVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text(this.editingId > 0 ? '编辑教室' : '新增教室').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }
            Button(this.formCampus || '选择校区').width('100%').backgroundColor('#EAF5F7').fontColor('#31566D')
              .onClick(() => this.formCampus = this.cycleRequiredText(this.formCampus, this.campuses))
            TextInput({ placeholder: '楼栋（必填）', text: this.formBuilding }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formBuilding = value)
            TextInput({ placeholder: '教室编号（必填）', text: this.formRoomNo }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formRoomNo = value)
            Button(this.formType || '选择教室类型').width('100%').backgroundColor('#EAF5F7').fontColor('#31566D')
              .onClick(() => this.formType = this.cycleRequiredText(this.formType, this.classroomTypes))
            TextInput({ placeholder: '容量（人数）', text: this.formCapacity }).type(InputType.Number).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formCapacity = value)
            TextInput({ placeholder: '面积（平方米）', text: this.formArea }).type(InputType.Number).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formArea = value)
            Button(this.statusText(this.formStatus)).width('100%').backgroundColor(this.statusBackground(this.formStatus)).fontColor(this.statusColor(this.formStatus))
              .onClick(() => this.formStatus = this.cycleRequiredText(this.formStatus, this.statuses))
            Button('保存静态数据').width('100%').height(48).backgroundColor('#197C93').fontColor(Color.White)
              .onClick(() => this.saveClassroom())
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('88%').height('82%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private deleteDialog() {
    if (this.deleteVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Column({ space: 14 }) {
          Text('确认删除教室？').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`将从当前静态预览中删除 ${this.selected.campus} ${this.selected.building} ${this.selected.roomNo}。`)
            .fontSize(14).fontColor('#516B80').width('100%')
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.deleteVisible = false)
            Button('确认删除').layoutWeight(1).backgroundColor('#B04A4A').fontColor(Color.White).onClick(() => this.deleteClassroom())
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
          Text('教室管理').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text(`${this.total}间`).fontSize(13).fontColor('#718096')
        }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row() {
          Text('远程数据').fontSize(12).fontColor('#176B87').backgroundColor('#DCEFF2')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(8)
          Text(this.loading ? '正在加载教室数据…' : '已连接后端接口').fontSize(12).fontColor('#718096').margin({ left: 8 })
        }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索教室编号或楼栋', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10)
            .onChange((value: string) => { this.keyword = value; this.currentPage = 1; this.loadClassrooms(); })
          Button('新增').height(40).backgroundColor('#176B87').onClick(() => this.openCreate())
          Button('筛选').height(40).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.filterVisible = true)
        }.width('100%').padding({ left: 20, right: 20, bottom: 8 })
        Text(`当前筛选：${this.campusFilter || '全部校区'} · ${this.typeFilter || '全部类型'} · ${this.statusFilter.length > 0 ? this.statusText(this.statusFilter) : '全部状态'}`)
          .fontSize(12).fontColor('#8999A4').width('100%').padding({ left: 20, right: 20, top: 4, bottom: 8 })
        if (this.visibleClassrooms().length === 0) {
          Column({ space: 10 }) {
            Text('暂无符合条件的教室').fontSize(16).fontColor('#516B80')
            Text('可调整筛选条件或新增教室').fontSize(13).fontColor('#8999A4')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.visibleClassrooms(), (item: ClassroomPreview) => { ListItem() { this.classroomCard(item) } }, (item: ClassroomPreview) => `${item.id}`)
          }.width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 16 })
        }
        Row({ space: 12 }) {
          Button('上一页').enabled(this.currentPage > 1).layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87')
            .onClick(() => { this.currentPage -= 1; this.loadClassrooms(); })
          Text(`第 ${this.currentPage} 页`).fontSize(13).fontColor('#516B80')
          Button('下一页').enabled(this.currentPage * this.pageSize < this.total).layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87')
            .onClick(() => { this.currentPage += 1; this.loadClassrooms(); })
        }.width('100%').padding({ left: 20, right: 20, bottom: 14 })
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.detailDialog()
      this.filterDialog()
      this.formDialog()
      this.deleteDialog()
    }.width('100%').height('100%')
  }
}
