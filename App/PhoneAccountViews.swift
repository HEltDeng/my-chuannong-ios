import SwiftUI

struct PlatformLoginView: View {
    @Environment(PlatformSession.self) private var platform
    @AppStorage(PrivacyConsent.storageKey) private var consent = false
    @State private var mode: PhoneAccountMode
    @State private var phone = ""
    @State private var nickname = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var error: String?
    @State private var remind = false
    @State private var support = false
    @FocusState private var focus: String?
    init(initialMode: PhoneAccountMode = .login) { _mode = State(initialValue: initialMode) }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image("BrandMark").resizable().scaledToFit()
                    .frame(width:64,height:64)
                    .clipShape(RoundedRectangle(cornerRadius:16,style:.continuous))
                    .accessibilityLabel("我的川农")
                Text(mode.title).font(.system(size:24,weight:.bold)).multilineTextAlignment(.center)
                VStack(spacing:16) {
                    if mode == .register {
                        field("昵称",hint:"昵称",text:$nickname,id:"nickname")
                            .onChange(of:nickname){_,v in nickname=String(v.prefix(30))}
                    }
                    field("手机号",hint:"11 位手机号",text:$phone,id:"phone")
                        .keyboardType(.phonePad).textContentType(.telephoneNumber)
                        .onChange(of:phone){_,v in phone=String(v.filter{$0.isASCII && $0.isNumber}.prefix(11))}
                    passwordField("密码",text:$password,id:"password")
                    if mode == .register {
                        passwordField("确认密码",text:$confirmation,id:"confirm-password")
                        if !confirmation.isEmpty,confirmation != password {
                            Text("两次输入的密码不一致").font(.subheadline).foregroundStyle(.red)
                                .frame(maxWidth:.infinity,alignment:.leading)
                        }
                    }
                    if let error {
                        Text(error).font(.subheadline).foregroundStyle(.red)
                            .frame(maxWidth:.infinity,alignment:.leading)
                    }
                    Button {
                        focus=nil
                        if mode == .register { remind=true } else { submit() }
                    } label: {
                        HStack {
                            if platform.busy { ProgressView().tint(.white) }
                            Text(mode == .login ? "登录" : "注册并进入")
                        }.frame(maxWidth:.infinity,minHeight:42)
                    }.buttonStyle(.borderedProminent).disabled(!canSubmit).accessibilityIdentifier("account-submit")
                    Button(mode == .login ? "创建账号" : "返回登录") {
                        switchMode(mode == .login ? .register : .login)
                    }.disabled(platform.busy)
                    Button("联系支持") { focus=nil;support=true }.disabled(platform.busy)
                    NavigationLink("隐私政策与用户协议") { LegalView() }.font(.subheadline)
                }.padding(18).background(ChuannongTheme.card,in:RoundedRectangle(cornerRadius:20))
            }.padding(.horizontal,22).padding(.vertical,24)
        }.background(ChuannongTheme.background).navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively).tint(ChuannongTheme.green)
            .disabled(platform.busy)
            .alert("请牢记密码",isPresented:$remind) {
                Button("确认并继续") { submit() };Button("返回检查",role:.cancel) {}
            } message: { Text(PhoneAccountRules.reminder) }
            .sheet(isPresented:$support) { SafariPage(url:URL(string:"https://mychuannong.cn/contact.html")!) }
    }
    private var canSubmit:Bool {
        guard !platform.busy,CampusContract.validPhone(phone),CampusContract.validPassword(password) else{return false}
        return mode == .login || (PhoneAccountRules.validConfirmation(password:password,confirmation:confirmation)
            && !nickname.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)
    }
    private func field(_ title:String,hint:String,text:Binding<String>,id:String)->some View {
        VStack(alignment:.leading,spacing:8) {
            Text(title).font(.subheadline)
            TextField(hint,text:text).textInputAutocapitalization(.never).autocorrectionDisabled()
                .focused($focus,equals:id).padding(13)
                .overlay(RoundedRectangle(cornerRadius:12).stroke(.secondary.opacity(0.3)))
                .accessibilityIdentifier(id)
        }
    }
    private func passwordField(_ title:String,text:Binding<String>,id:String)->some View {
        VStack(alignment:.leading,spacing:8) {
            Text(title).font(.subheadline)
            SecureField(mode == .login ? "请输入密码" : "至少 8 位",text:text)
                .textContentType(mode == .login ? .password : .newPassword)
                .focused($focus,equals:id).padding(13)
                .overlay(RoundedRectangle(cornerRadius:12).stroke(.secondary.opacity(0.3)))
                .accessibilityIdentifier(id)
        }.onChange(of:text.wrappedValue){_,v in text.wrappedValue=String(v.prefix(200))}
    }
    private func switchMode(_ next:PhoneAccountMode) {
        mode=next;password="";confirmation="";error=nil
    }
    private func submit() {
        guard canSubmit else{return};error=nil
        Task { do {
            try await platform.authenticate(phone:phone,password:password,
                nickname:mode == .register ? nickname : nil,consented:consent,
                confirmPassword:confirmation)
            password="";confirmation=""
        } catch { self.error=error.localizedDescription } }
    }
}

#if DEBUG
#Preview("创建平台账号") {
    NavigationStack { PlatformLoginView(initialMode:.register) }.environment(PlatformSession(loadSaved:false))
}
#endif
