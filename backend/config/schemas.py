from ninja import Schema


class ErrorSchema(Schema):
    type: str
    title: str
    detail: str | None
