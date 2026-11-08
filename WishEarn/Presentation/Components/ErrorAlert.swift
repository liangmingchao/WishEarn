import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?

    func body(content: Content) -> some View {
        content.alert(
            error?.title ?? "出了点问题",
            isPresented: Binding(
                get: { error != nil },
                set: { isPresented in
                    if !isPresented {
                        error = nil
                    }
                }
            ),
            presenting: error
        ) { _ in
            Button("知道了", role: .cancel) {}
        } message: { error in
            Text(error.message)
        }
    }
}

extension View {
    func appErrorAlert(error: Binding<AppError?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}
