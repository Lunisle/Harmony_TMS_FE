export interface ClassGroupInfo {
  id: number;
  name: string;
  grade: number;
  classNo: string;
}

export interface DepartmentInfo {
  id: number;
  name: string;
  code: string;
  type?: string | null;
}

export interface TeacherInfo {
  id: number;
  employeeNo: string;
  name: string;
}

export interface TeacherListItem {
  id: number;
  employeeNo: string;
  name: string;
  departmentId: number | null;
  departmentName: string | null;
  teacherType: string | null;
  title: string | null;
  phone: string | null;
}

export interface TeacherPage {
  items: TeacherListItem[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface TeacherOptionDepartment {
  id: number;
  name: string;
}

export interface TeacherOptions {
  departments: TeacherOptionDepartment[];
  titles: string[];
  teacherTypes: string[];
}

export interface TeacherMutationRequest {
  employeeNo: string;
  name: string;
  departmentId?: number;
  teacherType?: string;
  title?: string;
  phone?: string;
}

export interface DeleteResult {
  deleted: boolean;
}

export interface ClassroomListItem {
  id: number;
  campus?: string | null;
  building?: string | null;
  roomNo: string;
  type?: string | null;
  capacity: number;
  area?: number | null;
  status: string;
}

export interface ClassroomPage {
  items: ClassroomListItem[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ClassroomOptions {
  campuses: string[];
  buildings: string[];
  types: string[];
  statuses: string[];
}

export interface ClassroomMutationRequest {
  campus?: string;
  building?: string;
  roomNo?: string;
  type?: string;
  capacity?: number;
  area?: number;
  status?: string;
}

export interface CourseArrangementExam {
  id: number;
  semesterId?: number | null;
  classroomId?: number | null;
  classroomRoomNo?: string | null;
  startTime?: string | null;
  endTime?: string | null;
  invigilatorName?: string | null;
}

export interface CourseArrangementScheduleChange {
  id: number;
  status?: string;
  originalSchedule?: string | null;
  newSchedule?: string | null;
}

export interface CourseArrangementTextbookOrder {
  id: number;
  semesterId?: number | null;
  status?: string;
  quantity?: number | null;
}

export interface CourseArrangementTeachingLog {
  id: number;
  date?: string | null;
  topic?: string | null;
  content?: string | null;
}

export interface CourseArrangements {
  exams: CourseArrangementExam[];
  scheduleChanges: CourseArrangementScheduleChange[];
  textbookOrders: CourseArrangementTextbookOrder[];
  teachingLogs: CourseArrangementTeachingLog[];
}

export interface CourseDetail {
  id: number;
  code: string;
  name: string;
  credits: number;
  courseType?: string | null;
  departmentId?: number | null;
  departmentName?: string | null;
  directorId?: number | null;
  directorName?: string | null;
  department?: DepartmentInfo | null;
  director?: TeacherInfo | null;
  arrangements: CourseArrangements;
}

export interface CourseSummary {
  id: number;
  code: string;
  name: string;
  credits: number;
  courseType?: string | null;
  departmentId?: number | null;
  departmentName?: string | null;
  directorId?: number | null;
  directorName?: string | null;
}

export interface LinkedUserInfo {
  id: number;
  username?: string;
  enabled: boolean;
}

export interface StudentProfile {
  id: number;
  studentNo: string;
  name: string;
  className?: string | null;
  classGroupId: number | null;
  classGroup?: ClassGroupInfo | null;
  grade: number | null;
  status: string;
}

export interface StudentListItem {
  id: number;
  studentNo: string;
  name: string;
  classGroupId: number | null;
  classGroupName?: string | null;
  classGroup?: ClassGroupInfo | null;
  grade: number | null;
  status: string;
  phone?: string | null;
  user?: LinkedUserInfo | null;
  activated?: boolean;
  enabled?: boolean;
  departmentId?: number | null;
  departmentName?: string | null;
  majorId?: number | null;
  majorName?: string | null;
}

export interface StudentOptionDepartment {
  id: number;
  name: string;
}

export interface StudentOptionMajor {
  id: number;
  name: string;
  departmentId: number;
}

export interface StudentOptionClassGroup {
  id: number;
  name: string;
  grade: number;
  majorId: number;
  departmentId: number;
}

export interface StudentOptions {
  departments: StudentOptionDepartment[];
  majors: StudentOptionMajor[];
  classGroups: StudentOptionClassGroup[];
  grades: number[];
  statuses: string[];
}

export interface StudentMutationRequest {
  studentNo: string;
  name: string;
  classGroupId: number;
  grade: number;
  status: string;
  phone?: string | null;
}

export interface StudentPage {
  items: StudentListItem[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface StudentDetail extends StudentListItem {
  activated: boolean;
  enabled: boolean;
}

export interface UserInfo {
  id: number;
  username: string;
  name?: string;
  role: string;
  teacherId?: number | null;
  studentId?: number | null;
  student: StudentProfile | null;
  enabled?: boolean;
  departmentId?: number;
  department?: DepartmentInfo | null;
  teacher?: TeacherInfo | null;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginData {
  token: string;
  user: UserInfo;
}

export interface RegisterRequest {
  studentNo: string;
  name: string;
  password: string;
}

export interface RegisterData {
  user: UserInfo;
}

export interface ApiErrorData {
  code: string;
  message: string;
}

export interface ApiEnvelope<T> {
  success: boolean;
  data?: T;
  error?: ApiErrorData;
}
