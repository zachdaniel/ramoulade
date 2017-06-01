defmodule Ramoulade.Raml.V1.Root do
  defstruct [
    title: nil,
    media_type: [],
    description: nil,
    version: nil,
    base_uri: nil,
    protocols: [],
    media_type: [],
    documentation: nil,
    schemas: [],
    types: %{},
    traits: [],
    resource_types: [],
    annotation_types: [],
    annotations: [],
    security_schemes: [],
    secured_by: nil,
    relative_uri: nil,
    document: nil,
    type_inheritance: nil
  ]

  alias Ramoulade.Raml.Common

  def from_yaml(document, yaml) do
    %__MODULE__{
      title: Common.get_required_scalar!(document, yaml, "title"),
      description: Common.get_scalar!(document, yaml, "description"),
      document: document
    }
    |> add_types(yaml)
    |> add_version(yaml)
    |> add_media_type(yaml)
    |> add_base_uri(yaml)
    |> add_protocols(yaml)
    |> add_documentation(yaml)
    |> add_secured_by(yaml)
    |> add_security_schemes(yaml)
  end

  def add_version(root, yaml) do
    Map.put(root, :version, Common.get_string!(root.document, yaml, "version"))
  end

  def add_types(root, yaml) do
    yaml_types = Common.get_map!(root.document, yaml, "types")

    types = Enum.into(yaml_types, %{}, fn {name, value} ->
      type = Ramoulade.Raml.V1.Type.from_yaml(value, root, name)

      {name, type}
    end)

    root
    |> Map.put(:types, types)
    |> build_types()
  end

  def build_types(root = %{types: types}) do
    type_inheritance = Ramoulade.Raml.V1.TypeInheritance.from_types(types)

    new_types = Enum.into(types, %{}, fn {name, type} ->
      {name, type}
    end)


    %{root | types: new_types, type_inheritance: type_inheritance}
  end

  def add_documentation(root, yaml) do
    documentation = Common.get_list!(root.document, yaml, "documentation") || []
    Map.put(
      root,
      :documentation,
      Ramoulade.Raml.V1.Documentation.from_yaml(documentation, root))
  end

  def add_base_uri(root, yaml) do
    uri = Common.get_scalar!(root.document, yaml, "baseUri")
    uri_parameters = Common.get_map!(root.document, yaml, "baseUriParameters")

    if uri do
      Map.put(
        root,
        :base_uri,
        Ramoulade.Raml.V1.Uri.from_yaml(uri, root, uri_parameters)
      )
    else
      root
    end
  end

  def add_protocols(root, yaml) do
    protocols = Common.get_list!(root.document, yaml, "protocols")

    if protocols do
      sanitized_protocols = Enum.map(protocols, &String.upcase/1)
      unknown_protocols = Enum.reject(sanitized_protocols, fn protocol -> protocol in ["HTTP", "HTTPS"] end)
      if Enum.empty?(unknown_protocols) do
        Map.put(root, :protocols, sanitized_protocols)
      else
        Ramoulade.error!(root.document, "Unknown protocol or protocols #{unknown_protocols}, valid values are HTTP and HTTPS.")
      end
    else
      if root.base_uri do
        parsed_scheme = URI.parse(root.base_uri.uri).scheme
        if parsed_scheme do
          Map.put(root, :protocols, [String.upcase(parsed_scheme)])
        else
          root
        end
      else
        root
      end
    end
  end

  def add_media_type(root, yaml) do
    %{root | media_type: Common.get_list!(root.document, yaml, "mediaType", wrap_scalar?: true)}
  end

  def add_secured_by(root, yaml) do
    %{root | secured_by: Common.get_scalar!(root.document, yaml, "securedBy")}
  end

  def add_security_schemes(root, yaml) do
    security_schemes =
      root.document
      |> Common.get_map!(yaml, "securitySchemes")
      |> Enum.reduce(root.security_schemes, fn {key, yaml}, schemes ->
        Keyword.put(schemes, String.to_atom(key), Ramoulade.Raml.V1.SecurityScheme.from_yaml(yaml, root) )
      end)

    %{root | security_schemes: security_schemes}
  end
end
