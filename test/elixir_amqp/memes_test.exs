defmodule ElixirAMQP.MemesTest do
  use ElixirAMQP.DataCase

  alias ElixirAMQP.Memes
  alias ElixirAMQP.Schema.Meme

  describe "memes" do
    @valid_attrs %{
      id: 10_509_464,
      archived_url:
        "http://webarchive.loc.gov/all/19960101000000-20160901235959*/http://cdn.meme.am/instances/10509464.jpg",
      base_name: "Spiderman Approves",
      page_url: "http://memegenerator.net/instance/10509464",
      md5_hash: "5be4b65cc32d3a57be5b6693bb519155",
      file_size: 24_093,
      alternate_text: "seems legit"
    }
    @update_attrs %{
      id: 31_502_313,
      archived_url:
        "http://webarchive.loc.gov/all/19960101000000-20160901235959*/http://cdn.meme.am/instances/31502313.jpg",
      base_name: "Spiderman does not Approve",
      page_url: "http://memegenerator.net/instance/31502313",
      md5_hash: "1ce4b65cc32d3a57be5b6693bb519144",
      file_size: 19_000,
      alternate_text: "Fret not I stayed at a Holiday Inn Express last night"
    }
    @invalid_attrs %{
      id: nil,
      archived_url: nil,
      base_name: nil,
      page_url: nil,
      md5_hash: nil,
      file_size: nil,
      alternate_text: nil
    }

    def meme_fixture(attrs \\ %{}) do
      {:ok, meme} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Memes.create_meme()

      meme
    end

    test "list_with_pagination/0 returns all memes" do
      meme = meme_fixture()
      assert %Scrivener.Page{entries: entries} = Memes.list_with_pagination(%{})
      assert entries == [meme]
    end

    test "get_meme!/1 returns the meme with given id" do
      meme = meme_fixture()
      assert Memes.get_meme!(meme.id) == meme
    end

    test "create_meme/1 with valid data creates a meme" do
      assert {:ok, %Meme{} = meme} = Memes.create_meme(@valid_attrs)
      assert meme.id == 10_509_464

      assert meme.archived_url ==
               "http://webarchive.loc.gov/all/19960101000000-20160901235959*/http://cdn.meme.am/instances/10509464.jpg"

      assert meme.base_name == "Spiderman Approves"
      assert meme.page_url == "http://memegenerator.net/instance/10509464"
      assert meme.md5_hash == "5be4b65cc32d3a57be5b6693bb519155"
      assert meme.file_size == 24_093
      assert meme.alternate_text == "seems legit"
    end

    test "create_meme/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Memes.create_meme(@invalid_attrs)
    end

    test "update_meme/2 with valid data updates the meme" do
      meme = meme_fixture()
      assert {:ok, %Meme{} = meme} = Memes.update_meme(meme, @update_attrs)

      assert meme.id == 31_502_313

      assert meme.archived_url ==
               "http://webarchive.loc.gov/all/19960101000000-20160901235959*/http://cdn.meme.am/instances/31502313.jpg"

      assert meme.base_name == "Spiderman does not Approve"

      assert meme.page_url == "http://memegenerator.net/instance/31502313"
      assert meme.md5_hash == "1ce4b65cc32d3a57be5b6693bb519144"
      assert meme.file_size == 19_000
      assert meme.alternate_text == "Fret not I stayed at a Holiday Inn Express last night"
    end

    test "update_meme/2 with invalid data returns error changeset" do
      meme = meme_fixture()
      assert {:error, %Ecto.Changeset{}} = Memes.update_meme(meme, @invalid_attrs)
      assert meme == Memes.get_meme!(meme.id)
    end

    test "delete_meme/1 deletes the meme" do
      meme = meme_fixture()
      assert {:ok, %Meme{}} = Memes.delete_meme(meme)
      assert_raise Ecto.NoResultsError, fn -> Memes.get_meme!(meme.id) end
    end

    test "change_meme/1 returns a meme changeset" do
      meme = meme_fixture()
      assert %Ecto.Changeset{} = Memes.change_meme(meme)
    end
  end
end
