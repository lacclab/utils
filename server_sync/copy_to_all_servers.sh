# Check if user and server are provided as command line arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <user> <server>"
    exit 1
fi

user="$1"
server="$2"
rsync -avz --progress ~/.ssh/ $user@nlp$server.iem.technion.ac.il:/data/home/$user/.ssh
rsync -avz --progress ~/.zshrc $user@nlp$server.iem.technion.ac.il:/data/home/$user/
rsync -avz --progress ~/.p10k.zsh $user@nlp$server.iem.technion.ac.il:/data/home/$user/
rsync -avz --progress ~/Cognitive-State-Decoding/data/interim/ $user@nlp$server.iem.technion.ac.il:/data/home/$user/Cognitive-State-Decoding/data/interim