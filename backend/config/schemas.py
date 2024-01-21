from ninja import Schema


class Error(Schema):
    type: str
    title: str
    detail: str | None
