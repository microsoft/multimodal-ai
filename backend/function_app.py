import azure.functions as func
import logging
from app import create_app, bp, setup_clients, close_clients

func_app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@func_app.route(route="{*route}")
async def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    qapp=await create_app()
    await setup_clients()
    ret = await func.AsgiMiddleware(qapp).handle_async(req, context)
    await close_clients()
    return ret
