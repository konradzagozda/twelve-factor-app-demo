from ninja import NinjaAPI

api = NinjaAPI()

api.add_router("/todos/", "todos.api.router")
