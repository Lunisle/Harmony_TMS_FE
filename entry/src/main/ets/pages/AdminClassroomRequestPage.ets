import { ApiClient } from '../services/ApiClient';
import { ClassroomRequestListItem, ClassroomApproval } from '../models/ApiModels';

@Component
export struct AdminClassroomRequestPage {
  @Link page: number;
  @State requests: ClassroomRequestListItem[] = [];
  @State selected: ClassroomRequestListItem | null = null;
  @State loading: boolean = false;
  @State filterStatus: string = 'PENDING';
  @State comment: string = '';
  @State decisionVisible: boolean = false;
  @State detailVisible: boolean = false;
  @State decisionStatus: string = '';

  aboutToAppear(): void { void this.load(); }

  private async load(): Promise<void> {
    this.loading = true;
    try {
      const queryStatus = this.filterStatus.indexOf(',') >= 0 ? '' : this.filterStatus;
      const result = await ApiClient.getClassroomRequests(1, 100, queryStatus);
      this.requests = this.filterStatus.indexOf(',') >= 0 ? result.items.filter((item: ClassroomRequestListItem) => item.status !== 'PENDING') : result.items;
    } catch (error) { this.showToast(error instanceof Error ? error.message : '加载审批申请失败'); }
    finally { this.loading = false; }
  }

  private statusText(status: string): string {
    if (status === 'PENDING') return '待审批';
    if (status === 'APPROVED') return '已通过';
    if (status === 'REJECTED') return '已驳回';
    if (status === 'CANCELLED') return '已取消';
    if (status === 'COMPLETED') return '已完成';
    return '草稿';
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {}
  }

  private openDecision(item: ClassroomRequestListItem, status: string): void {
    this.selected = item;
    this.decisionStatus = status;
    this.comment = '';
    this.decisionVisible = true;
  }

  private openDetail(item: ClassroomRequestListItem): void {
    this.selected = item;
    this.detailVisible = true;
  }

  private async submitDecision(): Promise<void> {
    if (this.selected === null) return;
    if (this.decisionStatus === 'REJECTED' && this.comment.trim().length === 0) {
      this.showToast('驳回时必须填写审批意见');
      return;
    }
    try {
      await ApiClient.updateClassroomRequestStatus(this.selected.id, this.decisionStatus, this.comment.trim());
      this.decisionVisible = false;
      this.selected = null;
      await this.load();
      this.showToast(this.decisionStatus === 'APPROVED' ? '申请已通过' : '申请已驳回');
    } catch (error) { this.showToast(error instanceof Error ? error.message : '审批操作失败'); }
  }

  @Builder
  private requestRow(item: ClassroomRequestListItem) {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 4 }) {
          Text(`${item.classroomRoomNo} · ${item.applicantName}`).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#17324D')
          Text(`${item.classroomCampus ?? ''} · ${item.classroomBuilding ?? ''}`).fontSize(12).fontColor('#718096')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text(this.statusText(item.status)).fontSize(12).fontColor('#A66B21').backgroundColor('#FBF0DC').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9)
      }
      Row() { Text(`${item.startTime} 至 ${item.endTime}`).fontSize(12).fontColor('#516B80').layoutWeight(1); Text(`${item.participantCount} 人`).fontSize(12).fontColor('#516B80') }
      Text(item.purpose).fontSize(13).fontColor('#516B80').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 8 }) {
        Button('详情').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.openDetail(item))
        Button('通过').layoutWeight(1).backgroundColor('#DDF2EA').fontColor('#167C68').enabled(item.status === 'PENDING').onClick(() => this.openDecision(item, 'APPROVED'))
        Button('驳回').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').enabled(item.status === 'PENDING').onClick(() => this.openDecision(item, 'REJECTED'))
      }
    }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
  }

  @Builder
  private detailDialog() {
    if (this.detailVisible && this.selected !== null && !this.decisionVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Scroll() {
          Column({ space: 12 }) {
            Row() { Text('申请详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text(this.statusText(this.selected.status)).fontSize(12).fontColor('#176B87').backgroundColor('#E4F2F5').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9); Text('×').fontSize(25).fontColor('#718096').margin({ left: 8 }).onClick(() => this.detailVisible = false) }
            Row() { Text('申请人').width(78).fontColor('#718096'); Text(`${this.selected.applicantName}（${this.selected.applicantUsername}）`).fontColor('#17324D').layoutWeight(1) }
            Row() { Text('教室').width(78).fontColor('#718096'); Text(`${this.selected.classroomCampus ?? ''} · ${this.selected.classroomBuilding ?? ''} · ${this.selected.classroomRoomNo}`).fontColor('#17324D').layoutWeight(1) }
            Row() { Text('使用时间').width(78).fontColor('#718096'); Text(`${this.selected.startTime} 至 ${this.selected.endTime}`).fontColor('#17324D').layoutWeight(1) }
            Row() { Text('使用人数').width(78).fontColor('#718096'); Text(`${this.selected.participantCount} 人`).fontColor('#17324D').layoutWeight(1) }
            Row() { Text('用途').width(78).fontColor('#718096'); Text(this.selected.purpose).fontColor('#17324D').layoutWeight(1) }
            Text('审批记录').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#29445A').width('100%').margin({ top: 5 })
            if ((this.selected.approvalHistory ?? []).length === 0) {
              Text('暂无审批记录').fontSize(13).fontColor('#8999A4').width('100%')
            } else {
              ForEach(this.selected.approvalHistory ?? [], (approval: ClassroomApproval) => {
                Column({ space: 4 }) {
                  Text(`${approval.action} · ${approval.operator?.name ?? '系统'} · ${approval.createdAt}`).fontSize(13).fontColor('#516B80').width('100%')
                  Text(approval.comment ?? '未填写意见').fontSize(12).fontColor('#8999A4').width('100%')
                }.width('100%').padding(10).backgroundColor('#F1F6F8').borderRadius(9)
              }, (approval: ClassroomApproval) => `${approval.id}`)
            }
          }.width('88%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('100%').height('78%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private decisionDialog() {
    if (this.decisionVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.decisionVisible = false)
        Column({ space: 14 }) {
          Text(this.decisionStatus === 'REJECTED' ? '驳回申请' : '通过申请').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`${this.selected.classroomRoomNo} · ${this.selected.applicantName}`).fontSize(14).fontColor('#516B80').width('100%')
          TextInput({ placeholder: this.decisionStatus === 'REJECTED' ? '审批意见（必填）' : '审批意见（可选）', text: this.comment }).height(80).backgroundColor('#F1F6F8').borderRadius(10)
            .onChange((value: string) => this.comment = value)
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.decisionVisible = false)
            Button('确认').layoutWeight(1).backgroundColor(this.decisionStatus === 'REJECTED' ? '#B04A4A' : '#167C68').fontColor(Color.White).onClick(() => { void this.submitDecision(); })
          }
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() { Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0); Text('教室申请审批').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text(`${this.requests.length} 条`).fontSize(13).fontColor('#718096') }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row({ space: 8 }) {
          Button(this.filterStatus === 'PENDING' ? '待审批' : '已处理').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { this.filterStatus = this.filterStatus === 'PENDING' ? 'APPROVED,REJECTED,CANCELLED,COMPLETED' : 'PENDING'; void this.load(); })
          Button('刷新').width(80).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.load(); })
        }.width('100%').padding({ left: 20, right: 20, bottom: 10 })
        if (this.loading) { LoadingProgress().color('#176B87').layoutWeight(1) }
        else if (this.requests.length === 0) { Text('暂无申请记录').fontSize(16).fontColor('#718096').layoutWeight(1).margin({ top: 40 }) }
        else { List() { ForEach(this.requests, (item: ClassroomRequestListItem) => { ListItem() { this.requestRow(item) } }, (item: ClassroomRequestListItem) => `${item.id}`) }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 }) }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.detailDialog()
      this.decisionDialog()
    }.width('100%').height('100%')
  }
}
