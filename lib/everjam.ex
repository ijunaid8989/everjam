defmodule Everjam do
  def cameras() do
    CamBank.start_link()
    |> case do
      {:error, {:already_started, cam_bank}} ->
        CamBank.all(cam_bank)
        |> Enum.map(fn(cam_pid) -> Camera.details(cam_pid) end) |> IO.inspect()
      {:ok, _cam_bank} -> []
    end
  end

  def create_camera(url, username, password) do
    {:ok, camera} = Camera.start_link(%Camera.Attributes{
      url: url,
      username: username,
      password: password,
      name: generate_name(),
      status: "online",
      owner_id: 1
    })
    Process.whereis(CamBank)
    |> CamBank.add(camera)
  end

  defp generate_name() do
    [["autumn", "hidden", "bitter", "misty", "silent", "empty", "dry", "dark",
    "summer", "icy", "delicate", "quiet", "white", "cool", "spring", "winter",
    "patient", "twilight", "dawn", "crimson", "wispy", "weathered", "blue",
    "billowing", "broken", "cold", "damp", "falling", "frosty", "green",
    "long", "late", "lingering", "bold", "little", "morning", "muddy", "old",
    "red", "rough", "still", "small", "sparkling", "throbbing", "shy",
    "wandering", "withered", "wild", "black", "young", "holy", "solitary",
    "fragrant", "aged", "snowy", "proud", "floral", "restless", "divine",
    "polished", "ancient", "purple", "lively", "nameless"],
    ["waterfall", "river", "breeze", "moon", "rain", "wind", "sea", "morning",
    "snow", "lake", "sunset", "pine", "shadow", "leaf", "dawn", "glitter",
    "forest", "hill", "cloud", "meadow", "sun", "glade", "bird", "brook",
    "butterfly", "bush", "dew", "dust", "field", "fire", "flower", "firefly",
    "feather", "grass", "haze", "mountain", "night", "pond", "darkness",
    "snowflake", "silence", "sound", "sky", "shape", "surf", "thunder",
    "violet", "water", "wildflower", "wave", "water", "resonance", "sun",
    "wood", "dream", "cherry", "tree", "fog", "frost", "voice", "paper",
    "frog", "smoke", "star"]]
    |> Enum.map(fn(names) -> Enum.random(names) end)
    |> Enum.join("-")
  end
end
