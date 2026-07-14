import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { UserInfo } from '../models/ApiModels';

export interface SessionData {
  token: string;
  user: UserInfo;
}

export class SessionStore {
  private static readonly STORE_NAME: string = 'teaching_auth';
  private static readonly TOKEN_KEY: string = 'token';
  private static readonly USER_KEY: string = 'user';

  static async save(context: common.Context, token: string, user: UserInfo): Promise<void> {
    const store = await preferences.getPreferences(context, SessionStore.STORE_NAME);
    await store.put(SessionStore.TOKEN_KEY, token);
    await store.put(SessionStore.USER_KEY, JSON.stringify(user));
    await store.flush();
  }

  static async load(context: common.Context): Promise<SessionData | null> {
    const store = await preferences.getPreferences(context, SessionStore.STORE_NAME);
    const token = await store.get(SessionStore.TOKEN_KEY, '') as string;
    const userText = await store.get(SessionStore.USER_KEY, '') as string;
    if (!token || !userText) return null;

    try {
      return {
        token: token,
        user: JSON.parse(userText) as UserInfo
      };
    } catch (_) {
      return null;
    }
  }

  static async clear(context: common.Context): Promise<void> {
    const store = await preferences.getPreferences(context, SessionStore.STORE_NAME);
    await store.delete(SessionStore.TOKEN_KEY);
    await store.delete(SessionStore.USER_KEY);
    await store.flush();
  }
}
