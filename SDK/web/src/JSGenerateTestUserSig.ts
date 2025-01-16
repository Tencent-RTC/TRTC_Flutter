import LibGenerateTestUserSig from './lib/lib-generate-test-usersig';

export default class JsGenerateTestUserSig {
  constructor() {}
  public jsGenTestUserSig(SDKAPPID, SECRETKEY, userID, expireTime): string {
    const generator = new LibGenerateTestUserSig(
      SDKAPPID,
      SECRETKEY,
      expireTime
    );
    const userSig = generator.genTestUserSig(userID);
    return userSig;
  }
}
