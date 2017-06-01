defmodule Ramoulade.Raml.V1.Documentation do
  defstruct [:title, :content]

  alias Ramoulade.Raml.Common

  def from_yaml(yaml, root) do
    for doc_yaml <- yaml do
      new(doc_yaml, root)
    end
  end

  def new(yaml, root) do
    %__MODULE__{
      title: Common.get_required_scalar!(root.document, yaml, "title"),
      content: Common.get_required_scalar!(root.document, yaml, "content")
    }
  end
end
