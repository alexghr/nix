{ ... }:
{
  nix.settings = {
    extra-substituters = [
      "https://attic.alexghr.me/alexghr"
      "https://attic.alexghr.me/public"
    ];
    extra-trusted-public-keys = [
      "alexghr:5VNXw+55bVdl7SUk4K05TaXJKip7aU1v9KgKdHRTgbU="
      "public:5MqPjBBGMCWbo8L8voeQl7HXc5oX+MXZ6BSURfMosIo="
    ];
  };
}
