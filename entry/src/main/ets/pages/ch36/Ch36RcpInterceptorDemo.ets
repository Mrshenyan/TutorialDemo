import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * RCP interceptor demo.
 *
 * Interceptors are attached through SessionConfiguration.interceptors and run in array order
 * on the way OUT (request) and in reverse order on the way BACK (response) — a classic chain.
 *
 * A valid interceptor implements rcp.Interceptor:
 *   async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response>
 *   - mutate context.request before calling next.handle(context)
 *   - optionally await next.handle(context) to inspect/rewrite the response
 */

// Interceptor 1: inject a fixed auth header + trace id on every request.
class AuthInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    let headers: Record<string, string> = {}
    headers['Authorization'] = 'Bearer <your-token-here>'
    headers['X-Trace-Id'] = 'ch36-demo'
    context.request.headers = headers
    return next.handle(context)
  }
}

// Interceptor 2: log request/response and retry once on server 5xx errors.
class LoggingRetryInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    console.info(`[RCP] -> ${context.request.method} ${context.request.url.href}`)
    try {
      const resp: rcp.Response = await next.handle(context)
      console.info(`[RCP] <- ${resp.statusCode}`)
      if (resp.statusCode >= 500) {
        console.warn(`[RCP] 5xx detected, retry once`)
        return await next.handle(context)
      }
      return resp
    } catch (err) {
      const e: BusinessError = err as BusinessError
      console.error(`[RCP] error: ${e.message}`)
      return err
    }
  }
}

@Entry
@Component
struct Ch36RcpInterceptorDemo {
  @State log: string = 'Session 已挂上两个拦截器'

  async doRequest(): Promise<void> {
    // baseAddress lets you use relative paths in get()/fetch(); relative URLs are
    // joined onto baseAddress, absolute URLs ignore it.
    const sessionConfig: rcp.SessionConfiguration = {
      baseAddress: 'https://www.example.com',
      interceptors: [new AuthInterceptor(), new LoggingRetryInterceptor()]
    }
    const session: rcp.Session = rcp.createSession(sessionConfig)
    try {
      const response: rcp.Response = await session.get('/')
      this.log = `statusCode=${response.statusCode}\n(检查 Log -> 已自动带上 Authorization / X-Trace-Id)`
    } catch (err) {
      const e: BusinessError = err as BusinessError
      this.log = `err=${e.code}:${e.message}`
    } finally {
      session.close()
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('RCP 拦截器').fontSize(22).fontWeight(FontWeight.Bold)

      Button('发起带拦截器的请求')
        .width('90%')
        .onClick(() => { this.doRequest() })

      Text(this.log)
        .width('90%')
        .fontSize(13)
        .fontFamily('monospace')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
  }
}
