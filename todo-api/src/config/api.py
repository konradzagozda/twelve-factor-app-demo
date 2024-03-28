from ninja import NinjaAPI

from config.settings import BRANCH, TAG

api = NinjaAPI(title="TodoAPI", version=TAG, description=f"version: {TAG} branch: {BRANCH}")

api.add_router("/todos/", "todos.api.router")
